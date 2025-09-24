# frozen_string_literal: true

require 'rails_helper'

describe 'requesting a file remediation via the API', :active_job_inline do
  let!(:api_user) { create(:api_user, webhook_endpoint: 'https://example.com/webhooks') }
  let(:http_client) { instance_double Faraday::Connection }
  let(:request) { instance_spy Faraday::Request }

  before do
    allow(Faraday).to receive(:new).with(
      url: 'https://example.com/webhooks',
      headers: {
        'Content-Type' => 'application/json',
        'X-API-Key' => api_user.webhook_key
      }
    ).and_return(http_client)

    allow(http_client).to receive(:post).and_yield request
  end

  # it 'processes the file and sends a webhook notification' do
  #   # Here we're ensuring that even if we have configured our environment to use the real
  #   # AWS S3 bucket and PDF remediation tool, this test will still use MinIO and avoid
  #   # actually uploading the file to be remediated.
  #   with_minio_env do
  #     post(
  #       '/api/v1/jobs',
  #       params: {
  #         # This is brittle since we're doing an actual download of a file on the internet that we're
  #         # not hosting. For the purposes of this test, this felt a little better than trying to mock
  #         # out a file download. However, if this file disappears at some point, then the test will
  #         # fail, and we'll need to find a different public file to download.
  #         source_url: 'https://www.pa.gov/content/dam/copapwp-pagov/en/oa/documents/policies/it-policies/digital%20accessibility%20policy.pdf'
  #       },
  #       headers: { 'HTTP_X_API_KEY' => api_user.api_key }
  #     )
  #   end

  #   job = api_user.jobs.last

  #   expect(request).to have_received(:body=).with(
  #     "{\"event_type\":\"job.succeeded\",\"job\":{\"uuid\":\"#{job.uuid}\"," \
  #     "\"status\":\"completed\",\"output_url\":#{job.output_url.to_json}}}"
  #   )
  # end
end
