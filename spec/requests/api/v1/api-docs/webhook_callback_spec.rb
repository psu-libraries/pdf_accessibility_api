# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V1::WebhookCallbacks' do
  # Below describes the webhook notifications.  There are two definitions: one for job success and one for job failure.
  # This is not standard RSwag usage, and likely not OAS 3.0+ compliant, but it works for now.
  # TODO: Find some other way to document webhooks that uses OAS 3.0+ compliant callback definitions.
  path 'https://example.com/your/endpoint (when job succeeds)' do
    post 'Job succeeded webhook notification' do
      tags 'Webhook Callbacks'
      consumes 'application/json'
      description <<~DESC
        This is the webhook notification sent to your webhook endpoint when a job succeeds and finishes processing.

        Your webhook key will be provided in the headers (X-API-KEY) for you to authenticate the request.

        The body of the request is described below.
      DESC

      parameter name: :'X-API-KEY',
                in: :header,
                type: :string,
                description: 'Webhook key for authentication',
                required: true

      parameter name: :webhook, in: :body, schema: {
        type: :object,
        properties: {
          event_type: { type: :string, example: 'job.succeeded' },
          job: {
            type: :object,
            properties: {
              uuid: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' },
              status: { type: :string, example: 'completed' },
              output_url: { type: :string, format: :uri, example: 'https://example.com/output.pdf' }
            }
          }
        }
      }

      response '---', '------' do
        xit 'This is a doc-only example of an outbound webhook notification'
      end
    end
  end

  path 'https://example.com/your/endpoint (when job fails)' do
    post 'Job failed webhook notification' do
      tags 'Webhook Callbacks'
      consumes 'application/json'
      description <<~DESC
        This is the webhook notification sent to your webhook endpoint when a job fails to process.

        Your webhook key will be provided in the headers (X-API-KEY) for you to authenticate the request.

        The body of the request is described below.
      DESC

      parameter name: :'X-API-KEY',
                in: :header,
                type: :string,
                description: 'Webhook key for authentication',
                required: true

      parameter name: :webhook, in: :body, schema: {
        type: :object,
        properties: {
          event_type: { type: :string, example: 'job.failed' },
          job: {
            type: :object,
            properties: {
              uuid: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' },
              status: { type: :string, example: 'failed' },
              processing_error_message: { type: :string, example: 'An error occurred during processing' }
            }
          }
        }
      }

      response '---', '------' do
        xit 'This is a doc-only example of an outbound webhook notification'
      end
    end
  end
end
