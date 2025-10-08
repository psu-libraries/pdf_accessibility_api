# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob

  def perform(job_uuid, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    # To be implemented in #159
  end
end
