# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = [:post]

azure_auth_endpoint = ENV.fetch('AZURE_AUTH_ENDPOINT', nil)

issuer =
  azure_auth_endpoint&.sub(%r{/oauth2/v2\.0/authorize$}, '/v2.0')

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
             # Set redirect_uri dynamically at runtime to handle different hosts/FQDNs.
             # When behind a proxy/load balancer, the request host may be an internal IP.
             # Prefer using X-Forwarded-Host (or X-Forwarded-Server) when present.
             req = Rack::Request.new(env)
             strategy = env['omniauth.strategy']
             callback_path = Rails.application.routes.url_helpers.auth_azure_oauth_callback_path

             forwarded_host = req.get_header('HTTP_X_FORWARDED_HOST') || req.get_header('HTTP_X_FORWARDED_SERVER')
             host_with_port = forwarded_host.presence || req.host_with_port

             redirect_uri = "#{req.scheme}://#{host_with_port}#{callback_path}"
             strategy.options[:client_options][:redirect_uri] = redirect_uri
           },
           client_options: {
             identifier: ENV.fetch('AZURE_CLIENT_ID', nil),
             secret: ENV.fetch('AZURE_CLIENT_SECRET', nil)
           }
end
