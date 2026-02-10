# frozen_string_literal: true

RailsAdmin.config do |config|
  config.authenticate_with do
    unless AdminUserChecker.admin_user?(request)
      render plain: 'Forbidden', status: :forbidden
    end
  end

  config.current_user_method do
    warden.user
  end
end
