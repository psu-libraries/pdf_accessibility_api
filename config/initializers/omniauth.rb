OmniAuth.config.allowed_request_methods = [:get, :post]

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :openid_connect,
    name: :azure_oauth,
    scope: [:openid, :email, :profile],
    response_type: :code,
    issuer: "https://login.microsoftonline.com/#{ENV['AZURE_TENANT_ID']}/v2.0",
    discovery: true,
    client_auth_method: :query,
    uid_field: "email",
    client_options: {
      identifier: ENV['AZURE_CLIENT_ID'],
      secret: ENV['AZURE_CLIENT_SECRET'],
      redirect_uri: ENV.fetch("AZURE_REDIRECT_URI")
    }
end