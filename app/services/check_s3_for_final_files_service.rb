# frozen_string_literal: true

# This service class is meant to run continually in the background
class CheckS3ForFinalFilesService
  include AppJobModule

  CHECK_S3_PER_JOB_INTERVAL = 1 # Throttle S3 checks while iterating processing jobs
  CHECK_S3_IDLE_INTERVAL = 10 # Back off when there are no processing jobs
  CHECK_S3_FAILED_LIMIT = 3600 # 1 hour limit before marking job as failed

  def call(run_once: false)
    stop_requested = false

    unless run_once
      %w[TERM INT].each do |signal|
        Signal.trap(signal) { stop_requested = true }
      rescue ArgumentError
        nil
      end
    end

    loop do
      processed_any = false

      ActiveRecord::Base.connection_pool.with_connection do
        processing_jobs = Job.processing_pdfjobs

        if processing_jobs.none?
          break if run_once

          next
        end

        processing_jobs.find_each do |job|
          processed_any = true
          check_job(job)
          sleep CHECK_S3_PER_JOB_INTERVAL
          break if stop_requested
        rescue StandardError => e
          Bugsnag.notify(e) do |event|
            event.severity = 'error'
            event.context = 'CheckS3ForFinalFilesService#call'
          end
        end
      end

      break if run_once || stop_requested

      sleep CHECK_S3_IDLE_INTERVAL unless processed_any
    ensure
      ActiveRecord::Base.connection_handler.clear_active_connections!
    end
  end

  private

    def check_job(job)
      if job.created_at < CHECK_S3_FAILED_LIMIT.seconds.ago
        update_with_failure(job, 'Timed out waiting for output file')
        RemediationStatusNotificationJob.perform_later(job.uuid) if job.owner.instance_of?(::APIUser)
        return
      end

      s3_handler = S3Handler.new(job.output_object_key)
      output_url = s3_handler.presigned_url_for_output(job.filename,
                                                       expires_in: AppJobModule::PRESIGNED_URL_EXPIRES_IN)
      if output_url.present?
        update_job(job, output_url)
        RemediationStatusNotificationJob.perform_later(job.uuid) if job.owner.instance_of?(::APIUser)
      end
    end
end
