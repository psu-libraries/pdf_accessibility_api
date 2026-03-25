# frozen_string_literal: true

class ImageAltTextJob < ApplicationJob
  include AppJobModule

  def perform(job_uuid, tmp_path)
    job = find_job(job_uuid)
    alt_text = alt_text_client.process_image(
      tmp_path,
      prompt: prompt,
      model_id: model_id,
      temperature: temperature
    )
    complete_job(job, alt_text)
  rescue StandardError => e
    update_with_failure(job, e.message)
  ensure
    cleanup_tmpfile(tmp_path)
  end

  private

    def complete_job(job, alt_text)
      job.update(
        llm_model: resolve_llm_model,
        status: 'completed',
        finished_at: Time.zone.now,
        alt_text: alt_text
      )
    end

    def cleanup_tmpfile(path)
      FileUtils.rm_f(path)
    end

    def find_job(job_uuid)
      Job.find_by!(uuid: job_uuid)
    end

    def prompt
      Rails.root.join('prompt.txt').read
    end

    def model_id
      ENV.fetch('LLM_MODEL', 'default')
    end

    def resolve_llm_model
      AltText::LLMRegistry.resolve(model_id)
    end

    def alt_text_client
      @alt_text_client ||= AltText::Client.new(**alt_text_client_config)
    end

    def alt_text_client_config
      {
        access_key: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
        secret_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil),
        region: ENV.fetch('AWS_REGION', 'us-east-1')
      }
    end
end

private

def temperature
  raw = ENV.fetch('LLM_TEMPERATURE', '0.0').to_f
  [[raw, 0.0].max, 1.0].min
end