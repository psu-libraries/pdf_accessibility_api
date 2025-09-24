# frozen_string_literal: true

require 'rails_helper'

describe 'Jobs' do
  include RemediationModule

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:original_filename) { 'testing.pdf' }
  let!(:content_type) { 'application/pdf' }

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
      with_minio_env do
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
    end

    it 'creates a record to track the job status' do
      with_minio_env do
        expect {
          post(
            '/jobs/sign', headers: valid_headers, params: { filename: original_filename }
          )
        }.to(change { gui_user.jobs.count }.by(1))
        job = gui_user.jobs.last
        expect(job.status).to eq 'processing'
      end
    end
  end

  describe 'POST jobs/complete' do
    let!(:job) { create(:job, :gui_user_job) }

    it 'updates the related job' do
      with_minio_env do
        post(
          '/jobs/complete', headers: valid_headers, params: {
            job_id: job.id,
            output_url: 'www.test.com',
            output_object_key: 'test output key'
          }
        )
        reloaded_job = job.reload
        expect(reloaded_job.status).to eq 'completed'
        expect(reloaded_job.output_url).to eq 'www.test.com'
        expect(reloaded_job.output_object_key).to eq 'test output key'
      end
    end
  end
end
