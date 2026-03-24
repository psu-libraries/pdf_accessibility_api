# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']

    raw_info = auth.dig('extra', 'raw_info') || {}
    # UPN (User Principal Name) is the user's unique identifier in Entra ID
    # In our case, it is the PSU Access ID followed by @psu.edu
    email = raw_info['upn']
    roles = raw_info['roles'] || []

    unless roles.include?(ENV['AUTHORIZED_USERS_ROLE'])
      render plain: 'Forbidden', status: :forbidden
      return
    end

    user = GUIUser.find_or_create_by!(email:)
    session[:user_id] = user.id
    session[:admin]   = roles.include?(ENV.fetch('ADMIN_USERS_ROLE', nil))

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
