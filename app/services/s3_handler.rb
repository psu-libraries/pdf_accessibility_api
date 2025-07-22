# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Handler
  class Error < RuntimeError; end

  INPUT_PREFIX = 'pdf/'
  OUTPUT_PREFIX = 'result/COMPLIANT_'

  def initialize(object_key)
    @object_key = object_key
    @s3 = Aws::S3::Resource.new(
      region: ENV.fetch('AWS_REGION'),
      credentials: Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )
    )
    @bucket = @s3.bucket(ENV.fetch('S3_BUCKET_NAME'))
  end

  def upload_to_input(local_path)
    key = "#{INPUT_PREFIX}#{@object_key}"
    @bucket.object(key)
      .upload_file(local_path)
  rescue Aws::Errors::ServiceError => e
    raise Error.new(e)
  end

  def presigned_url_for_output(expires_in: 3600)
    obj = find_file(prefix: OUTPUT_PREFIX)
    return nil unless obj

    obj.presigned_url(:get, expires_in: expires_in)
  rescue Aws::Errors::ServiceError => e
    raise Error.new(e)
  end

  private

    def find_file(prefix: INPUT_PREFIX)
      key = "#{prefix}#{@object_key}"
      obj = @bucket.object(key)
      obj.exists? ? obj : nil
    end
end
