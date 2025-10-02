# frozen_string_literal: true

class APIRemediationJob < ApplicationJob
  include RemediationModule

  def perform(job_uuid, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    job = Job.find_by!(uuid: job_uuid)
    tempfile = Down.download(job.source_url)
    original_filename = tempfile&.original_filename
    object_key = "#{SecureRandom.hex(8)}_#{original_filename}"
    file_path = tempfile&.path
    s3 = S3Handler.new(object_key)
    s3.upload_to_input(file_path)
    poll_and_update(job_uuid, object_key, output_polling_timeout)
  rescue S3Handler::Error => e
    record_failure_and_notify(job, "Failed to upload file to remediation input location:  #{e.message}")
  rescue Down::Error => e
    # We may want to retry the download depending on the more specific nature of the failure.
    record_failure_and_notify(job, "Failed to download file from source URL:  #{e.message}")
  ensure
    RemediationStatusNotificationJob.perform_later(job_uuid)
    tempfile&.close!
  end
end
