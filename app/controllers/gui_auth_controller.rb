# frozen_string_literal: true

class GUIAuthController < ApplicationController
  before_action :authenticate_gui_user

  def authenticate_gui_user
    request.env['warden'].authenticate!
  end
end
