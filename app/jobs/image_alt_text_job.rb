# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, tmp_path, output_polling_timeout: 10)
    client = AltText::Client.new(
      access_key: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
      region: ENV.fetch('AWS_REGION', 'us-east-1')
    )
    job = Job.find_by!(uuid: job_uuid)
    timer = 0
    until alt_text = client.process_image(tmp_path, prompt: File.read('prompt.txt'),
                                                    model_id: ENV.fetch('LLM_MODEL', nil))
      sleep OUTPUT_POLLING_INTERVAL
      timer += OUTPUT_POLLING_INTERVAL
      if timer > output_polling_timeout
        update_with_failure(job, 'Timed out waiting for alt-text')
        FileUtils.rm_f(tmp_path)
        return true
      end
    end
    job.update(
      status: 'completed',
      finished_at: Time.zone.now,
      alt_text: alt_text
    )
    FileUtils.rm_f(tmp_path)
  rescue StandardError => e
    update_with_failure(job, e.message)
  end
end
