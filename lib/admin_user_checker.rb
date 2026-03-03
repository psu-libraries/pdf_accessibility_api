# frozen_string_literal: true

class AdminUserChecker
  def self.admin_user?(request, user: nil)
    admin_users = Rails.application.config_for(:warden)['admin_users'].split(',').map(&:strip)
    authenticated_user = user || request.env['warden']&.user
    user_email = authenticated_user&.email

    admin_users.include?(user_email)
  end
end
