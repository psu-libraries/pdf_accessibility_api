# frozen_string_literal: true

require 'rails_helper'

describe 'API V1 jobs', type: :request do
  before { allow(RemediationJob).to receive(:perform_later) }

  let!(:api_user) { create(:api_user) }
  let(:valid_headers) { { 'HTTP_X_API_KEY' => api_user.api_key } }
  let(:valid_source_url) { 'https://test.com/file' }

  describe 'POST /api/v1/jobs' do
    context 'when given a valid API key' do
      context 'when given valid params' do
        it 'creates a record to track the job status' do
          expect {
            post(
              '/api/v1/jobs',
              params: { source_url: valid_source_url },
              headers: valid_headers
            )
          }.to(change { api_user.jobs.count }.by(1))

          job = api_user.jobs.last
          expect(job.status).to eq 'processing'
          expect(job.source_url).to eq valid_source_url
        end

        it 'enqueues a new job' do
          post '/api/v1/jobs', params: { source_url: valid_source_url }, headers: valid_headers

          expect(RemediationJob).to have_received(:perform_later).with(api_user.jobs.last.uuid)
        end

        it 'returns an ok response with the job UUID' do
          post '/api/v1/jobs', params: { source_url: valid_source_url }, headers: valid_headers

          expect(response).to be_ok
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['uuid']).to eq api_user.jobs.last.uuid
        end
      end

      context 'when given invalid params' do
        it 'returns an unprocessable entity response' do
          post '/api/v1/jobs', params: { source_url: 'bad url' }, headers: valid_headers

          expect(response).to be_unprocessable
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['message']).to eq 'Validation failed: Source url is invalid'
          expect(parsed_response['code']).to eq 422
        end
      end
    end

    context 'when given an invalid API key' do
      it 'returns and unauthorized response' do
        post '/api/v1/jobs', headers: { 'HTTP_X_API_KEY' => 'bad_api_key' }

        expect(response).to be_unauthorized
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq 'Not authorized'
        expect(parsed_response['code']).to eq 401
      end
    end
  end
end
