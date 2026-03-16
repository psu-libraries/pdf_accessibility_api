# frozen_string_literal: true

require 'rails_helper'
require 'azure_oidc_config'

RSpec.describe AzureOidcConfig do
  describe '.redirect_uri_for' do
    let(:strategy) do
      instance_double(OmniAuth::Strategies::OpenIDConnect, options: { client_options: {} })
    end

    let(:env) do
      Rack::MockRequest.env_for(
        '/auth/azure_oauth',
        'rack.url_scheme' => scheme,
        'HTTP_HOST' => host_with_port,
        'omniauth.strategy' => strategy
      )
    end

    let(:scheme) { 'https' }
    let(:host_with_port) { 'example.test:4443' }

    it 'builds a redirect_uri using the request scheme, host, and callback path' do
      env_with_port = Rack::MockRequest.env_for(
        '/auth/azure_oauth',
        'rack.url_scheme' => scheme,
        'HTTP_HOST' => host_with_port,
        'omniauth.strategy' => strategy
      )
      callback_path = Rails.application.routes.url_helpers.auth_azure_oauth_callback_path
      expect(
        described_class.redirect_uri_for(env_with_port)
      ).to eq("#{scheme}://#{host_with_port}#{callback_path}")
    end
  end

  describe '.issuer_for' do
    it 'transforms an Azure v2.0 authorize endpoint into an issuer URL' do
      endpoint = 'https://login.microsoftonline.com/tenant-id/oauth2/v2.0/authorize'

      expect(described_class.issuer_for(endpoint)).to eq(
        'https://login.microsoftonline.com/tenant-id/v2.0'
      )
    end

    it 'returns nil when the endpoint is nil' do
      expect(described_class.issuer_for(nil)).to be_nil
    end

    it 'returns the original string when it does not match the expected pattern' do
      endpoint = 'https://login.microsoftonline.com/tenant-id/other/path'

      expect(described_class.issuer_for(endpoint)).to eq(endpoint)
    end
  end
end
