# frozen_string_literal: true

require 'rails_helper'
require 'timeout'

# End-to-end test for remediation upload through the API.
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

  # TODO: This test is flaky. It downloads a real PDF from the internet and depends on
  # external resources. The test is marked as pending until we can mock the remediation
  # tool or use a more reliable local file.
  # rubocop:disable RSpec/PendingWithoutReason
  xit 'sends webhook notification on remediation', skip: 'Requires external resources' do
    pending 'Requires external resources'
    # Here we're ensuring that even if we have configured our environment to use the real
    # rubocop:enable RSpec/PendingWithoutReason
    # AWS S3 bucket and PDF remediation tool, this test will still use MinIO and avoid
    # actually uploading the file to be remediated.
    with_minio_env do
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

      # In production, CheckS3ForFinalFilesService runs continuously.
      # In specs, we poll deterministically until the job completes.
      service = CheckS3ForFinalFilesService.new
      allow(service).to receive(:sleep) # speed up per-job throttle

      job = api_user.jobs.last
      Timeout.timeout(120) do
        # 600 attempts * 0.2s sleep = 120 second timeout
        max_attempts = 600
        attempts = 0
        until job.reload.completed? || attempts >= max_attempts
          service.call(run_once: true)
          sleep 0.2
          attempts += 1
        end
      end

      expect(request).to have_received(:body=).with(
        "{\"event_type\":\"job.succeeded\",\"job\":{\"uuid\":\"#{job.uuid}\"," \
        "\"status\":\"completed\",\"output_url\":#{job.output_url.to_json}}}"
      )
    end
  end
end
