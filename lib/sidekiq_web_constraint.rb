# frozen_string_literal: true

class SidekiqWebConstraint
  def matches?(request)
    user = request.env[Rails.application.config_for(:warden)['remote_user_header']]
    sidekiq_users = Rails.application.config_for(:warden)['sidekiq_users'].split(',')
    sidekiq_users.include?(user)
  end
end
