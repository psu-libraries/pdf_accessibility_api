# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V1::Jobs' do
  path '/api/v1/jobs' do
    post 'Creates a job' do
      tags 'Jobs'
      consumes 'application/json'
      produces 'application/json'
      security [ApiKeyAuth: []]

      parameter name: :'X-API-KEY',
                in: :header,
                type: :string,
                description: 'API key for authentication',
                required: true

      parameter name: :job, in: :body, schema: {
        type: :object,
        properties: {
          source_url: { type: :string, format: :uri, example: 'https://example.com/file.pdf' }
        },
        required: ['source_url']
      }

      response '200', 'job created' do
        let(:X_API_KEY) { 'valid_api_key' }
        let(:job) { { source_url: 'https://example.com/file.pdf' } }

        schema type: :object,
               properties: {
                 uuid: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' }
               },
               required: ['uuid']
        run_test!
      end

      response '401', 'unauthorized' do
        let(:X_API_KEY) { nil }
        let(:job) { { source_url: 'https://example.com/file.pdf' } }

        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Not Authorized' },
                 code: { type: :integer, example: 401 }
               },
               required: ['message', 'code']

        run_test!
      end

      response '422', 'invalid request' do
        let(:X_API_KEY) { 'valid_api_key' }
        let(:job) { { source_url: '' } }

        schema type: :object,
               properties: {
                 message: { type: :string, example: "Validation failed: Source url can't be blank" },
                 code: { type: :integer, example: 422 }
               },
               required: ['message', 'code']

        run_test!
      end
    end
  end

  path 'https://example.com/your/webhook' do
    post 'Job succeeded webhook notification' do
      tags 'Webhook'
      consumes 'application/json'
      description 'Webhook notification sent to your webhook endpoint when a job is successfully processed'

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

      response '200', '------' do
        # skip actual test run — just for docs
        run_test! do |_|
          skip 'This is a doc-only example of an outbound webhook'
        end
      end
    end
  end

  path "https://example.com/your/webhook\u200B" do
    post 'Job failed webhook notification' do
      tags 'Webhook'
      consumes 'application/json'
      description 'Webhook notification sent to your webhook endpoint when a job is failed'

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

      response '200', '------' do
        # skip actual test run — just for docs
        run_test! do |_|
          skip 'This is a doc-only example of an outbound webhook'
        end
      end
    end
  end
end
