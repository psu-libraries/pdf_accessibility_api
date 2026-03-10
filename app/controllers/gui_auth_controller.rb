# frozen_string_literal: true

class GUIAuthController < ApplicationController
  before_action :require_login

  def require_login
    redirect_to '/auth/azure_oauth' unless current_user
  end
end
