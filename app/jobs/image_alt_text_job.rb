# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, tmp_path)
    client = AltText::Client.new(
      access_key: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
      secret_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
      region: ENV.fetch('AWS_REGION', 'us-east-1')
    )
    job = Job.find_by!(uuid: job_uuid)
    alt_text = client.process_image(
      tmp_path,
      prompt: File.read(Rails.root.join("prompt.txt")),
      model_id: ENV.fetch('LLM_MODEL', 'nil')
    )
    job.update(
      status: 'completed',
      finished_at: Time.zone.now,
      alt_text: alt_text
    )
  rescue StandardError => e
    update_with_failure(job, e.message)
  ensure
    FileUtils.rm_f(tmp_path)
  end
end
