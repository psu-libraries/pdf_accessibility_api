# frozen_string_literal: true

class APIRemediationJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    job = PdfJob.find_by!(uuid: job_uuid)
    tempfile = Down.download(job.source_url)
    original_filename = tempfile&.original_filename
    job.update!(output_object_key: original_filename)
    safe_original_filename = original_filename.gsub(/[^A-Za-z0-9.\-_ ]/, '')
    object_key = "#{SecureRandom.hex(8)}_#{safe_original_filename}"
    file_path = tempfile&.path
    s3_handler = S3Handler.new(object_key)
    s3_handler.upload_to_input(file_path)
    poll_and_update(job_uuid, s3_handler, output_polling_timeout)
  rescue S3Handler::Error => e
    update_with_failure(job, "Failed to upload file to remediation input location:  #{e.message}")
  rescue Down::Error, ActiveRecord::RecordInvalid => e
    # We may want to retry the download depending on the more specific nature of the failure.
    update_with_failure(job, "Failed to download file from source URL:  #{e.message}")
  ensure
    RemediationStatusNotificationJob.perform_later(job_uuid)
    tempfile&.close!
  end
end
