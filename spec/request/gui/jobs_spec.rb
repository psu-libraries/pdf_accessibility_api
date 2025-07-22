# frozen_string_literal: true

require 'rails_helper'

describe 'Gui jobs', type: :request do
  before { allow(RemediationJob).to receive(:perform_later) }

  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:valid_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => gui_user.email } }
  let!(:file_upload) { Rack::Test::UploadedFile.new(File.new("#{Rails.root}/spec/fixtures/files/testing.pdf"),
                                                    'application.pdf',
                                                    original_filename: 'testing.pdf')}

  describe 'GET gui/new' do
    it 'gets a successful response' do
      get '/gui/new', headers: valid_headers
      expect(response).to have_http_status :ok
    end

    it 'displays page' do
      get '/gui/new', headers: valid_headers
      expect(response.body).to include(I18n.t('ui_page.heading'))
    end
  end

  describe 'POST gui/create' do
    it 'creates a record to track the job status' do
      expect {
        post(
          '/gui/create', headers: valid_headers, params: { job: { file: file_upload } }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
    end

    it 'enqueues a job with RemediationJob' do
      post(
        '/gui/create', headers: valid_headers, params: { job: { file: file_upload } }
      )
      expect(RemediationJob).to have_received(:perform_later).with(gui_user.jobs.last.uuid)
    end

    it 'redirects to new page' do
      post(
        '/gui/create', headers: valid_headers, params: { job: { file: file_upload } }
      )
      expect(response).to redirect_to(gui_new_path)
    end

    context 'when an error occurs' do
      let!(:doubled_job) { instance_double(Job) }

      before do
        allow(Job).to receive(:new).and_return(doubled_job)
        allow(doubled_job).to receive(:new_record?).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'displays an error when one occurs' do
        post(
          '/gui/create', headers: valid_headers, params: { job: { file: file_upload } }
        )
        expect(flash[:alert]).to eq(I18n.t('ui_page.upload.error'))
      end
    end
  end
end
