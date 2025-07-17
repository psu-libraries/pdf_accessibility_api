# frozen_string_literal: true

redis_password = ENV.fetch('REDIS_PASSWORD', 'redispassword')
redis_host = ENV.fetch('REDIS_HOST', 'localhost')
redis_port = ENV.fetch('REDIS_PORT', '6379')
redis_url = "redis://:#{redis_password}@#{redis_host}:#{redis_port}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
