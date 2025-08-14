# frozen_string_literal: true

class ShrineConfig
  CACHE_PREFIX = ENV.fetch('SHRINE_CACHE_PREFIX', 'cache')
  PROMOTION_PREFIX = ENV.fetch('SHRINE_PROMOTION_PREFIX', 'store')

  class << self
    def storages
      {
        cache: Shrine::Storage::S3.new(prefix: CACHE_PREFIX, **s3_options),
        store: Shrine::Storage::S3.new(prefix: PROMOTION_PREFIX, **s3_options),
      }
    end

    def s3_options
      if ENV.key?('S3_ENDPOINT')
        base_options.merge(endpoint: ENV['S3_ENDPOINT'], force_path_style: true)
      else
        base_options
      end
    end

    def base_options
      {
        bucket: ENV['S3_BUCKET_NAME'],
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: ENV['AWS_REGION']
      }
    end
  end
end
