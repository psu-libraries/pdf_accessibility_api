# frozen_string_literal: true

require 'rails_helper'

describe 'requesting a file remediation via the API', type: :request do
  let!(:api_user) { create(:api_user, webhook_endpoint: 'https://example.com/webhooks') }
  let(:http_client) { instance_double Faraday::Connection }
  let(:request) { instance_spy Faraday::Request }

  before do
    # We have a separate test that specifically exercies our connection to the AWS S3
    # bucket used by the real remediation tool. Here we're testing our API workflow
    # without depending on the real S3 bucket by substituting in MinIO and a trivial
    # script that doubles for the remediation tool behavior.
    ENV['S3_ENDPOINT'] = 'http://minio:9000'

    allow(Faraday).to receive(:new).with(
      url: 'https://example.com/webhooks',
      headers: {
        'Content-Type' => 'application/json',
        'X-API-Key' => api_user.webhook_key
      }
    ).and_return(http_client)

    allow(http_client).to receive(:post).and_yield request
  end

  after { ENV['S3_ENDPOINT'] = nil }

  it 'processes the file and sends a webhook notification' do
    original_bucket_name = ENV.fetch('S3_BUCKET_NAME', nil)
    original_key_id = ENV.fetch('AWS_ACCESS_KEY_ID', nil)
    original_key = ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
    ENV['S3_BUCKET_NAME'] = 'pdf_accessibility_api'
    ENV['AWS_ACCESS_KEY_ID'] = 'pdf_accessibility_api'
    ENV['AWS_SECRET_ACCESS_KEY'] = 'pdf_accessibility_api'

    post(
      '/api/v1/jobs',
      params: {
        # This is brittle since we're doing an actual download of a file on the internet that we're
        # not hosting. For the purposes of this test, this felt a little better than trying to mock
        # out a file download. However, if this file disappears at some point, then the test will
        # fail, and we'll need to find a different public file to download.
        source_url: 'https://www.pa.gov/content/dam/copapwp-pagov/en/oa/documents/policies/it-policies/digital%20accessibility%20policy.pdf'
      },
      headers: { 'HTTP_X_API_KEY' => api_user.api_key }
    )

    job = api_user.jobs.last

    until job.status == 'completed'
      sleep 1
    end

    expect(request).to have_received(:body=).with(
      "{\"event_type\":\"job.succeeded\",\"job\":{\"uuid\":\"#{job.uuid}\"," \
      "\"status\":\"completed\",\"output_url\":#{job.output_url.to_json}}}"
    )

    ENV['S3_BUCKET_NAME'] = original_bucket_name
    ENV['AWS_ACCESS_KEY_ID'] = original_key_id
    ENV['AWS_SECRET_ACCESS_KEY'] = original_key
  end
end
