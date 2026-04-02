# frozen_string_literal: true

require 'rails_helper'
require 'azure_oidc_config'

RSpec.describe AzureOidcConfig do
  describe '.redirect_uri_for' do
    subject(:redirect_uri) { described_class.redirect_uri_for(env) }

    let(:strategy) do
      instance_double(OmniAuth::Strategies::OpenIDConnect, options: { client_options: {} })
    end

    let(:scheme) { 'https' }
    let(:host_with_port) { 'example.test:4443' }
    let(:forwarded_host) { nil }
    let(:forwarded_server) { nil }
    let(:callback_path) { Rails.application.routes.url_helpers.auth_azure_oauth_callback_path }

    let(:mock_request_headers) do
      {
        'rack.url_scheme' => scheme,
        'HTTP_HOST' => host_with_port,
        'omniauth.strategy' => strategy
      }.tap do |headers|
        headers['HTTP_X_FORWARDED_HOST'] = forwarded_host if forwarded_host
        headers['HTTP_X_FORWARDED_SERVER'] = forwarded_server if forwarded_server
      end
    end

    let(:env) { Rack::MockRequest.env_for('/auth/azure_oauth', mock_request_headers) }

    context 'when no forwarded headers are present' do
      it 'builds a redirect_uri using the request scheme, host, and callback path' do
        expect(redirect_uri).to eq("#{scheme}://#{host_with_port}#{callback_path}")
      end
    end

    context 'when HTTP_X_FORWARDED_HOST is set' do
      let(:forwarded_host) { 'external.example.org' }

      it 'prefers HTTP_X_FORWARDED_HOST' do
        expect(redirect_uri).to eq("#{scheme}://#{forwarded_host}#{callback_path}")
      end
    end

    context 'when HTTP_X_FORWARDED_SERVER is set and HTTP_X_FORWARDED_HOST is not set' do
      let(:forwarded_server) { 'external-server.example.org' }

      it 'uses HTTP_X_FORWARDED_SERVER' do
        expect(redirect_uri).to eq("#{scheme}://#{forwarded_server}#{callback_path}")
      end
    end

    context 'when both HTTP_X_FORWARDED_HOST and HTTP_X_FORWARDED_SERVER are set' do
      let(:forwarded_host) { 'external-host.example.org' }
      let(:forwarded_server) { 'external-server.example.org' }

      it 'prefers HTTP_X_FORWARDED_HOST over HTTP_X_FORWARDED_SERVER' do
        expect(redirect_uri).to eq("#{scheme}://#{forwarded_host}#{callback_path}")
      end
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
