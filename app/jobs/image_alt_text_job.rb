# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob

  def perform(job_uuid, uploaded_io, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    # To be fully implemented in #159
    # Create file and path from uploaded io
    # tmp_path = Rails.root.join('tmp', 'uploads', SecureRandom.hex + File.extname(uploaded_io.original_filename))
    # FileUtils.mkdir_p(File.dirname(tmp_path))
    # File.open(tmp_path, 'wb') { |f| f.write(uploaded_io.read) }
    # Call AltTextGem with path, prompt, llm_model
    # Poll and reroute
    # File.delete(tmp_path) if File.exist?(tmp_path)
  end
end
