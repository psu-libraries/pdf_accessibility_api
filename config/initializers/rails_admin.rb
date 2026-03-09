# frozen_string_literal: true

RailsAdmin.config do |config|
  config.authenticate_with do
    unless AdminUserChecker.admin_user?(request, user: warden.user)
      render plain: 'Forbidden', status: :forbidden
    end
  end

  config.current_user_method do
    warden.user
  end
end

Rails.application.config.to_prepare do
  RailsAdmin::ApplicationController.helper(RailsAdmin::DashboardHelper)
end
