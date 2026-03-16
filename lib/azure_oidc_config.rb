# frozen_string_literal: true

module AzureOidcConfig
  def self.redirect_uri_for(env)
    req = Rack::Request.new(env)
    callback_path = Rails.application.routes.url_helpers.auth_azure_oauth_callback_path
    "#{req.scheme}://#{req.host_with_port}#{callback_path}"
  end

  def self.issuer_for(auth_endpoint)
    return nil if auth_endpoint.nil?

    auth_endpoint.sub(%r{/oauth2/v2\.0/authorize$}, '/v2.0')
  end
end
