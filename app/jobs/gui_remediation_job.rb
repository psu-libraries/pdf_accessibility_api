# frozen_string_literal: true

class GUIRemediationJob < ApplicationJob
  include RemediationModule

  def perform(job_uuid, file_path, original_filename, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    upload_and_update(job_uuid, file_path, original_filename, output_polling_timeout)
  ensure
    File.delete(file_path) if File.exist?(file_path.to_s)
  end
end
