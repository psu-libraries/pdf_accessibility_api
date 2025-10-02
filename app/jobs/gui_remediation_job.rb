# frozen_string_literal: true

class GUIRemediationJob < ApplicationJob
  include RemediationModule

  def perform(job_uuid, object_key, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    upload_and_update(job_uuid, object_key, output_polling_timeout)
  end
end
