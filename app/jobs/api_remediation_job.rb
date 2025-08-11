# frozen_string_literal: true

class APIRemediationJob < ApplicationJob
  include RemediationModule

  def perform(job_uuid, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    job = Job.find_by!(uuid: job_uuid)
    tempfile = Down.download(job.source_url)
    original_filename = tempfile&.original_filename
    file_path = tempfile&.path
    upload_and_update(job_uuid, file_path, original_filename, output_polling_timeout)

  rescue Down::Error => e
    # We may want to retry the download depending on the more specific nature of the failure.
    record_failure_and_notify(job, "Failed to download file from source URL:  #{e.message}")
  ensure
    RemediationStatusNotificationJob.perform_later(job_uuid)
    tempfile&.close!
  end
end
