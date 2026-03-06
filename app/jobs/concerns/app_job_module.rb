# frozen_string_literal: true

module AppJobModule
  PRESIGNED_URL_EXPIRES_IN = 84_000 # 24 hours

  private

    def update_job(job, output_url)
      job.update(
        status: 'completed',
        finished_at: Time.zone.now,
        output_url: output_url,
        output_url_expires_at: PRESIGNED_URL_EXPIRES_IN.seconds.from_now
      )
    end

    def update_with_failure(job, message)
      job.update(
        status: 'failed',
        finished_at: Time.zone.now,
        processing_error_message: message
      )
    end
end
