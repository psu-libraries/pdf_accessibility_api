# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, uploaded_io, output_polling_timeout: OUTPUT_POLLING_TIMEOUT)
    tmp_path = Rails.root.join('app','tmp', 'uploads', SecureRandom.hex + uploaded_io.original_filename).to_s
    FileUtils.mkdir_p(File.dirname(tmp_path))
    File.open(tmp_path, 'wb') { |f| f.write(uploaded_io.read) }
    client = AltText::Client.new(
      access_key: ENV['AWS_ACCESS_KEY_ID'],
      secret_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
    job = Job.find_by!(uuid: job_uuid)
    timer = 0
    until alt_text = client.process_image(tmp_path, prompt: File.read('prompt.txt'), model_id: ENV['LLM_MODEL'])
      sleep OUTPUT_POLLING_INTERVAL
      timer += OUTPUT_POLLING_INTERVAL
      if timer > output_polling_timeout
        update_with_failure(job, 'Timed out waiting for alt-text')
        File.delete(tmp_path) if File.exist?(tmp_path)
        return true
      end
    end
    job.update(
      status: 'completed',
      finished_at: Time.zone.now,
      alt_text: alt_text
    )
    File.delete(tmp_path) if File.exist?(tmp_path)
  rescue StandardError => e
    update_with_failure(job, e.message)
  end
end
