# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url(SIDEKIQ_REDIS_DB) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url(SIDEKIQ_REDIS_DB) }
end
