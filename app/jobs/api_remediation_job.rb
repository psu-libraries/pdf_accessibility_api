# frozen_string_literal: true

class APIRemediationJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    job = PdfJob.find_by!(uuid: job_uuid)
    tempfile = nil
    tempfile = Down.download(job.source_url)
    original_filename = tempfile&.original_filename
    job.update!(output_object_key: original_filename)

    page_count = PDF::Reader.new(tempfile.path).page_count
    PageCountQuotaValidator.validate!(owner: job.owner, page_count: page_count)
    job.update!(page_count: page_count)

    safe_original_filename = original_filename.gsub(/[^A-Za-z0-9.\-_ ]/, '')
    object_key = "#{SecureRandom.hex(8)}_#{safe_original_filename}"
    file_path = tempfile&.path
    s3_handler = S3Handler.new(object_key)
    s3_handler.upload_to_input(file_path)
    poll_and_update(job_uuid, s3_handler, output_polling_timeout)
  rescue Down::Error,
         S3Handler::Error,
         PDF::Reader::MalformedPDFError,
         PageCountQuotaValidator::Error => e
    # We may want to retry the download depending on the more specific nature of the failure.
    update_with_failure(job, "Failed to process job: #{e.class}: #{e.message}")
  ensure
    RemediationStatusNotificationJob.perform_later(job_uuid)
    tempfile&.close!
  end
end
