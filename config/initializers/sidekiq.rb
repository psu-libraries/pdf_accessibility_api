# frozen_string_literal: true

redis_password = ENV.fetch('REDIS_PASSWORD', 'redis_password')
redis_host = ENV.fetch('REDIS_HOST', 'localhost')
redis_port = ENV.fetch('REDIS_PORT', '6379')
redis_url = "redis://:#{redis_password}@#{redis_host}:#{redis_port}/0"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Set concurrency
  config.options[:concurrency] = ENV.fetch('SIDEKIQ_CONCURRENCY', 5).to_i

  # Global default max retries for jobs (note: can be overridden per job class)
  Sidekiq.default_worker_options = {
    'retry' => ENV.fetch('SIDEKIQ_MAX_RETRIES', 3).to_i
  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
