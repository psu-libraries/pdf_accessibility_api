# frozen_string_literal: true

module AzureOidcConfig
  def self.redirect_uri_for(env)
    # When behind a proxy/load balancer, the request host may be an internal IP.
    # Prefer using X-Forwarded-Host (or X-Forwarded-Server) when present.
    
    req = Rack::Request.new(env)
    strategy = env['omniauth.strategy']
    callback_path = Rails.application.routes.url_helpers.auth_azure_oauth_callback_path

    forwarded_host = req.get_header('HTTP_X_FORWARDED_HOST') || req.get_header('HTTP_X_FORWARDED_SERVER')
    host_with_port = forwarded_host.presence || req.host_with_port

    redirect_uri = "#{req.scheme}://#{host_with_port}#{callback_path}"
  end

  def self.issuer_for(auth_endpoint)
    return nil if auth_endpoint.nil?

    auth_endpoint.sub(%r{/oauth2/v2\.0/authorize$}, '/v2.0')
  end
end
