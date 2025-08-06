# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'API::V1::Jobs' do
  before do
    create(:api_user, api_key: valid_api_key)
  end

  let(:valid_api_key) { 'valid_api_key' }

  path '/api/v1/jobs' do
    post 'Creates a job' do
      tags 'Jobs'
      consumes 'application/json'
      produces 'application/json'
      description <<~DESC
        This endpoint allows you to submit a PDF for remediation.

        You must provide a valid API key in the `X-API-KEY` header to authenticate your request.

        The body of the request must include a `source_url` parameter with the URL of the PDF to be remediated.

        On success, the response will include a UUID for your job.#{'  '}

        A delayed callback will be sent to your configured webhook URL when the job is complete.

        Refer to the Webhook Callbacks section for details on the webhook notifications.
      DESC
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
        let(:'X-API-KEY') { valid_api_key }
        let(:job) { { source_url: 'https://example.com/file.pdf' } }

        schema type: :object,
               properties: {
                 uuid: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' }
               },
               required: ['uuid']
        run_test!
      end

      response '401', 'unauthorized' do
        let(:'X-API-KEY') { nil }
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
        let(:'X-API-KEY') { valid_api_key }
        let(:job) { { source_url: 'example_invalid' } }

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
end
