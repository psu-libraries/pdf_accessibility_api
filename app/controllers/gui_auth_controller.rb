# frozen_string_literal: true

class GUIAuthController < ApplicationController
  before_action :auto_login

  def auto_login
    render 'sessions/auto_login' unless current_user
  end
end
