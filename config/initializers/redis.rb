# frozen_string_literal: true
SIDEKIQ_REDIS_DB = 0
ACTION_CABLE_REDIS_DB = 1

REDIS_CONFIG = {
  password: ENV['REDIS_PASSWORD'].presence,
  host: ENV.fetch('REDIS_HOST', 'localhost'),
  port: ENV.fetch('REDIS_PORT', '6379')
}.freeze

def redis_url(db_index)
  if REDIS_CONFIG[:password].present?
    "redis://:#{REDIS_CONFIG[:password]}@#{REDIS_CONFIG[:host]}:#{REDIS_CONFIG[:port]}/#{db_index}"
  else
    "redis://#{REDIS_CONFIG[:host]}:#{REDIS_CONFIG[:port]}/#{db_index}"
  end
end
