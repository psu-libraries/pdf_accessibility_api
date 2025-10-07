# frozen_string_literal: true

class RemediationStatusNotificationJob < ApplicationJob
  def perform(job_uuid)
    job = PdfJob.find_by!(uuid: job_uuid)

    body = if job.completed?
             {
               event_type: 'job.succeeded',
               job: job.as_json(only: [:uuid, :status, :output_url])
             }
           else
             {
               event_type: 'job.failed',
               job: job.as_json(only: [:uuid, :status, :processing_error_message])
             }
           end

    conn = Faraday.new(
      url: job.webhook_endpoint,
      headers: {
        'Content-Type' => 'application/json',
        'X-API-Key' => job.webhook_key
      }
    )

    conn.post do |req|
      req.body = body.to_json
    end
  end
end
