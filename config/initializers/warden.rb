# frozen_string_literal: true

Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.failure_app = CustomFailureApp

  manager.default_strategies :http_header_auth
end

Warden::Strategies.add(:http_header_auth) do
  def valid?
    request.env[Rails.application.config_for(:warden)['remote_user_header']].present?
  end

  def authenticate!
    user = request.env[Rails.application.config_for(:warden)['remote_user_header']]
    authorized_users = Rails.application.config_for(:warden)['authorized_users'].split(',')
    if authorized_users.include?(user)
      email = env['HTTP_X_AUTH_REQUEST_EMAIL']
      success! GUIUser.find_or_create_by!(email:)
    else
      fail!(user)
    end
  end
end
