# frozen_string_literal: true

require 'rails_helper'

describe 'PDF Jobs' do
  before { allow(GUIRemediationJob).to receive(:perform_later) }

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:original_filename) { 'testing.pdf' }

  describe 'GET pdf_jobs/new' do
    it 'gets a successful response' do
      get '/pdf_jobs/new', headers: valid_headers
      expect(response).to have_http_status :ok
    end

    it 'displays page' do
      get '/pdf_jobs/new', headers: valid_headers
      expect(response.body).to include(I18n.t('heading'))
    end
  end

  describe 'POST pdf_jobs/sign' do
    let(:example_json) do {
      url: 'www.example.com',
      headers: {
        'Content-Type' => 'application/pdf'
      },
      job_id: '1',
      object_key: 'example object key'
    }
    end

    let(:s3) {
      instance_spy(
        S3Handler,
        presigned_url_for_input: example_json
      )
    }

    before do
      allow(S3Handler).to receive(:new).and_return s3
    end

    it 'returns json created by S3Handler' do
      post(
        '/pdf_jobs/sign', headers: valid_headers, params: { filename: original_filename }
      )
      expect(response).to be_ok
      parsed_body = response.parsed_body
      expect(s3).to have_received(:presigned_url_for_input)
      expect(parsed_body).to eq(example_json.with_indifferent_access)
    end
  end

  describe 'POST pdf_jobs/complete' do
    it 'creates a record to track the job status' do
      expect {
        post(
          '/pdf_jobs/complete', headers: valid_headers, params: { object_key: '12345678_testing.pdf' }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
    end

    it 'enqueues a job with GUIRemediationJob' do
      post(
        '/pdf_jobs/complete', headers: valid_headers, params: { object_key: '12345678_testing.pdf' }
      )
      expect(GUIRemediationJob).to have_received(:perform_later)
    end
  end
end
