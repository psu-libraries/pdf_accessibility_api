# frozen_string_literal: true

module AdminAccessHelper
  def admin_user?
    user = request.env[Rails.application.config_for(:warden)['remote_user_header']]
    admin_users = Rails.application.config_for(:warden)['admin_users'].split(',')
    admin_users.include?(user)
  end
end
