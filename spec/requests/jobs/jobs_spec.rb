# frozen_string_literal: true

require 'rails_helper'

describe 'Jobs' do
  before { allow(GUIRemediationJob).to receive(:perform_later) }

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:original_filename) { 'testing.pdf' }

  describe 'GET jobs/new' do
    it 'gets a successful response' do
      get '/jobs/new', headers: valid_headers
      expect(response).to have_http_status :ok
    end

    it 'displays page' do
      get '/jobs/new', headers: valid_headers
      expect(response.body).to include(I18n.t('heading'))
    end
  end

  describe 'POST jobs/create' do
    let!(:file_upload) { Rack::Test::UploadedFile.new(File.new("#{Rails.root}/spec/fixtures/files/testing.pdf"),
                                                      'application.pdf',
                                                      original_filename:)}

    it 'creates a record to track the job status' do
      expect {
        post(
          '/jobs', headers: valid_headers, params: { file: file_upload }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
    end

    it 'enqueues a job with GUIRemediationJob' do
      post(
        '/jobs', headers: valid_headers, params: { file: file_upload }
      )
      expect(GUIRemediationJob).to have_received(:perform_later)
    end

    it 'redirects to new page' do
      post(
        '/jobs', headers: valid_headers, params: { file: file_upload }
      )
      expect(response).to redirect_to(job_path(Job.last))
    end

    context 'when an error occurs' do
      it 'displays an error' do
        post(
          '/jobs/', headers: valid_headers, params: { file: {} }
        )
        expect(flash[:alert]).to eq(I18n.t('upload.error'))
      end
    end
  end
end
