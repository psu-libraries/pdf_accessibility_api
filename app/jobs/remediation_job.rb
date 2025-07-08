# frozen_string_literal: true

class RemediationJob < ApplicationJob
  def perform(job_uuid)
    job = Job.find_by!(uuid: job_uuid)
    tempfile = Down.download(job.source_url)
    object_key = "#{SecureRandom.hex(8)}_#{tempfile.original_filename}"
    s3 = S3Handler.new(object_key)
    s3.upload_to_input(tempfile.path)

    until output_url = s3.presigned_url_for_output
      sleep 10 # This value was picked somewhat arbitrarily. We may want to adjust.

      # We'll probably want this to time out eventually and record a failure if the
      # output file isn't found after some reasonably long period of time, but I don't
      # think that we know how long we should wait yet. Also, I don't yet know if there
      # is any other way to detect a file remediation failure apart from the absence of
      # an output file. If there is, then we'll want to check for that.
    end

    job.update(
      status: 'completed',
      finished_at: Time.zone.now,
      output_url: output_url,
      output_object_key: object_key
    )

    RemediationStatusNotificationJob.perform_later(job_uuid)
  rescue Down::Error => e
    # We may want to retry the download depending on the more specific nature of the failure.
    record_failure(job, "Failed to download file from source URL:  #{e.message}")
  rescue S3Handler::Error => e
    # We may want to retry the upload depending on the more specific nature of the failure.
    record_failure(job, "Failed to upload file to remediation input location:  #{e.message}")
  ensure
    tempfile&.close!
  end

  private

    def record_failure(job, message)
      job.update(
        status: 'failed',
        finished_at: Time.zone.now,
        processing_error_message: message
      )
    end
end
