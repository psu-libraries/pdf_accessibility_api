# frozen_string_literal: true

require 'rails_helper'

describe 'Image Jobs' do
  before { allow(ImageAltTextJob).to receive(:perform_later) }

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:file_upload) { Rack::Test::UploadedFile.new(File.new("#{Rails.root}/spec/fixtures/files/lion.jpg"),
                                                    'image/jpg',
                                                    original_filename: 'lion.jpg')}

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
          '/image_jobs', headers: valid_headers, params: { image: file_upload }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
      expect(job.alt_text).to eq 'Generating...'
    end

    it 'enqueues a job with ImageAltTextJob' do
      post(
        '/image_jobs', headers: valid_headers, params: { image: file_upload }
      )
      expect(ImageAltTextJob).to have_received(:perform_later)
    end

    it 'returns valid JSON' do
      post(
        '/image_jobs', headers: valid_headers, params: { image: file_upload }
      )
      job = gui_user.jobs.last
      expected_response = { 'jobId' => job.id }
      expect(response.parsed_body).to eq(expected_response)
    end
  end
end
