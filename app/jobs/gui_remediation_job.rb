# frozen_string_literal: true

class GUIRemediationJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, object_key, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    poll_and_update(job_uuid, object_key, output_polling_timeout)
  end
end
