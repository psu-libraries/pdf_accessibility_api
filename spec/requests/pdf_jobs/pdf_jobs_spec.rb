# frozen_string_literal: true

require 'rails_helper'

describe 'PDF Jobs' do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu', unit: create(:unit)) }
  let!(:original_filename) { 'testing.pdf' }

  before do
    login_gui_user(gui_user)
  end

  describe 'GET pdf_jobs/new' do
    it 'gets a successful response' do
      get '/pdf_jobs/new'
      expect(response).to have_http_status :ok
    end

    it 'displays page' do
      get '/pdf_jobs/new'
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
        '/pdf_jobs/sign', params: { filename: original_filename, page_count: 3 }
      )
      expect(response).to be_ok
      parsed_body = response.parsed_body
      expect(s3).to have_received(:presigned_url_for_input)
      expect(parsed_body).to eq(example_json.with_indifferent_access)
    end

    it 'returns unprocessable entity when page count exceeds quota' do
      job_count_before = PdfJob.count
      allow(PageCountQuotaValidator).to receive(:validate!).and_raise(
        PageCountQuotaValidator::QuotaExceededError,
        "page_count exceeds the unit's overall page limit of 5"
      )

      post(
        '/pdf_jobs/sign', params: { filename: original_filename, page_count: 10 }
      )

      expect(response).to be_unprocessable
      parsed_body = response.parsed_body
      expect(parsed_body['message']).to eq("Page count exceeds the unit's overall page limit of 5")
      expect(parsed_body['code']).to eq(422)
      expect(PdfJob.count).to eq(job_count_before)
    end
  end

  describe 'POST pdf_jobs/complete' do
    it 'creates a record to track the job status' do
      expect {
        post(
          '/pdf_jobs/complete', params: { object_key: '12345678_testing.pdf', page_count: 3 }
        )
      }.to(change { gui_user.jobs.count }.by(1))
      job = gui_user.jobs.last
      expect(job.status).to eq 'processing'
      expect(job.page_count).to eq 3
    end
  end
end
