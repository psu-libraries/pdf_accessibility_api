# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemediationStatusNotificationJob do
  let(:user) { create(:api_user, webhook_endpoint: 'https://test.com/webhook') }
  let!(:job) {
    create(
      :job,
      status: status,
      owner: user,
      output_url: 'https://example.com/output',
      processing_error_message: 'failed to process'
    )
  }
  let(:status) { 'completed' }
  let(:http_client) { instance_double Faraday::Connection }
  let(:request) { instance_spy Faraday::Request }

  before do
    allow(Faraday).to receive(:new).with(
      url: 'https://test.com/webhook',
      headers: {
        'Content-Type' => 'application/json',
        'X-API-Key' => job.webhook_key
      }
    ).and_return(http_client)

    allow(http_client).to receive(:post).and_yield request
  end

  describe '#perform' do
    context 'when the given job is completed' do
      it "POSTs a success notification to the job's webhook endpoint" do
        described_class.perform_now(job.uuid)

        expect(request).to have_received(:body=).with(
          "{\"event_type\":\"job.succeeded\",\"job\":{\"uuid\":\"#{job.uuid}\"," \
          '"status":"completed","output_url":"https://example.com/output"}}'
        )
      end
    end

    context 'when the given job has failed' do
      let(:status) { 'failed' }

      it "POSTs a failure notification to the job's webhook endpoint" do
        described_class.perform_now(job.uuid)

        expect(request).to have_received(:body=).with(
          "{\"event_type\":\"job.failed\",\"job\":{\"uuid\":\"#{job.uuid}\"," \
          '"status":"failed","processing_error_message":"failed to process"}}'
        )
      end
    end
  end
end
