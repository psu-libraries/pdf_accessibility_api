# frozen_string_literal: true

require 'rails_helper'

describe 'Jobs' do
  include RemediationModule

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:original_filename) { 'testing.pdf' }
  let!(:content_type) {'application/pdf'}
  let!(:size) {'9000'}

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

  describe 'POST jobs/sign' do
    it 'returns appropriate json' do
      post(
        '/jobs/sign', headers: valid_headers, params: { filename: original_filename }
      )
      expect(response).to be_ok
      parsed_body = response.parsed_body
      object_key = create_object_key(original_filename)
      s3_handler = S3Handler.new(object_key)
      id = gui_user.jobs.last.id
      expect(parsed_body).to eq(
        s3_handler.presigned_url_for_input(original_filename, content_type, id).with_indifferent_access
      )
    end

    it 'creates a record to track the job status' do
      expect {
        post(
          '/jobs/sign', headers: valid_headers, params: { file: original_filename, original_filename:, size: }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
    end
  end
end
