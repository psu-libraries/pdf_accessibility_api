# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    email = auth.dig('info', 'email')
    groups = auth.dig('extra', 'raw_info', 'groups') || []

    unless groups.include?(ENV['AUTHORIZED_USERS_GROUP'])
      render plain: 'Forbidden', status: :forbidden
      return
    end

    user = GUIUser.find_or_create_by!(email:)
    session[:user_id] = user.id
    session[:admin]   = groups.include?(ENV.fetch('ADMIN_USERS_GROUP', nil))

    redirect_to root_path
  end

  def failure
    error_message = params[:message]&.humanize || 'Authentication failed'
    render plain: "Authentication failed: #{error_message}", status: :unauthorized
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
