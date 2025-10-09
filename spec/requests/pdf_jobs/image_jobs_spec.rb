# frozen_string_literal: true

require 'rails_helper'

describe 'Image Jobs' do
  before { allow(ImageAltTextJob).to receive(:perform_later) }

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:mock_io) { {'original_filename' => 'lion.jpg'} }

  describe 'GET image_jobs/new' do
    it 'gets a successful response' do
      get '/image_jobs/new', headers: valid_headers
      expect(response).to have_http_status :ok
    end

    it 'displays page' do
      get '/image_jobs/new', headers: valid_headers
      expect(response.body).to include(I18n.t('heading'))
    end
  end

  describe 'POST image_jobs' do
    it 'creates a record to track the job status' do
      expect {
        post(
          '/image_jobs', headers: valid_headers, params: { image: mock_io }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
    end

    it 'enqueues a job with GUIRemediationJob' do
      post(
        '/image_jobs', headers: valid_headers, params: { image: mock_io }
      )
      expect(ImageAltTextJob).to have_received(:perform_later)
    end
  end
end
