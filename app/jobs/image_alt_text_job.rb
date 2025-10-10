# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob
  def perform(job_uuid, uploaded_io, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    # To be implemented in #159
    # Open the file file in a temp/uploads path
    # Call AltTextGem with path, prompt, llm_model
    # Poll and reroute
    # File.delete(tmp_path) if File.exist?(tmp_path)
  end
end
