# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = [:post]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
           name: :azure_oauth,
           scope: [:openid, :email, :profile],
           response_type: :code,
           issuer: "https://login.microsoftonline.com/#{ENV.fetch('AZURE_TENANT_ID', nil)}/v2.0",
           discovery: true,
           client_auth_method: :query,
           uid_field: 'email',
           client_options: {
             identifier: ENV.fetch('AZURE_CLIENT_ID', nil),
             secret: ENV.fetch('AZURE_CLIENT_SECRET', nil),
             redirect_uri: ENV.fetch('AZURE_REDIRECT_URI')
           }
end
