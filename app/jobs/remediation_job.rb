# frozen_string_literal: true

class RemediationJob < ApplicationJob
  OUTPUT_POLLING_INTERVAL = 10 # This value was picked somewhat arbitrarily. We may want to adjust.
  PRESIGNED_URL_EXPIRES_IN = 84_000

  # The default 1-hour timeout is also arbitrary and should probably be adjusted.
  def perform(job_uuid, output_polling_timeout: 3600, file_path: nil, original_filename: nil)
    job = Job.find_by!(uuid: job_uuid)
    tempfile = Down.download(job.source_url) if job.source_url.present?
    filename = tempfile&.original_filename || original_filename
    path = tempfile&.path || file_path

    object_key = "#{SecureRandom.hex(8)}_#{filename}"
    s3 = S3Handler.new(object_key)
    s3.upload_to_input(path)

    timer = 0

    until output_url = s3.presigned_url_for_output(expires_in: PRESIGNED_URL_EXPIRES_IN)
      sleep OUTPUT_POLLING_INTERVAL
      timer += OUTPUT_POLLING_INTERVAL

      if timer > output_polling_timeout
        record_failure_and_notify(job, 'Timed out waiting for output file')
        return true
      end
    end

    job.update(
      status: 'completed',
      finished_at: Time.zone.now,
      output_url: output_url,
      output_object_key: object_key,
      output_url_expires_at: PRESIGNED_URL_EXPIRES_IN.seconds.from_now
    )

    RemediationStatusNotificationJob.perform_later(job_uuid)
  rescue Down::Error => e
    # We may want to retry the download depending on the more specific nature of the failure.
    record_failure_and_notify(job, "Failed to download file from source URL:  #{e.message}")
  rescue S3Handler::Error => e
    # We may want to retry the upload depending on the more specific nature of the failure.
    record_failure_and_notify(job, "Failed to upload file to remediation input location:  #{e.message}")
  ensure
    tempfile&.close!
    File.delete(file_path) if File.exist?(file_path.to_s)
  end

  private

    def record_failure_and_notify(job, message)
      job.update(
        status: 'failed',
        finished_at: Time.zone.now,
        processing_error_message: message
      )

      RemediationStatusNotificationJob.perform_later(job.uuid)
    end
end
