# frozen_string_literal: true

require 'azure_oidc_config'

OmniAuth.config.allowed_request_methods = [:post]

azure_auth_endpoint = ENV.fetch('AZURE_AUTH_ENDPOINT', nil)

issuer = AzureOidcConfig.issuer_for(azure_auth_endpoint)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
           name: :azure_oauth,
           scope: [:openid, :email, :profile],
           response_type: :code,
           issuer: issuer,
           discovery: true,
           client_auth_method: :query,
           uid_field: 'email',
           setup: lambda { |env|
             # Set redirect_uri dynamically at runtime to handle different hosts/FQDNs
             strategy = env['omniauth.strategy']
             strategy.options[:client_options][:redirect_uri] = AzureOidcConfig.redirect_uri_for(env)
           },
           client_options: {
             identifier: ENV.fetch('AZURE_CLIENT_ID', nil),
             secret: ENV.fetch('AZURE_CLIENT_SECRET', nil)
           }
end
