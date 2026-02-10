# frozen_string_literal: true

RailsAdmin.config do |config|
  config.authenticate_with do
    extend AdminAccessHelper

    unless admin_user?
      render plain: 'Forbidden', status: :forbidden
    end
  end

  config.current_user_method do
    warden.user
  end
end
