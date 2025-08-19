# frozen_string_literal: true

require 'aws-sdk-s3'

class S3Handler
  class Error < RuntimeError; end

  INPUT_PREFIX = 'pdf/'
  OUTPUT_PREFIX = 'result/COMPLIANT_'

  attr_reader :bucket

  def initialize(object_key)
    @object_key = object_key
    client_options = {
      credentials: Aws::Credentials.new(
        ENV.fetch('AWS_ACCESS_KEY_ID'),
        ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )
    }
    if ENV['S3_ENDPOINT'].present?
      client_options[:endpoint] = ENV['S3_ENDPOINT']
    else
      client_options[:region] = ENV.fetch('AWS_REGION')
    end

    @s3_client = Aws::S3::Client.new(client_options)
    @s3 = Aws::S3::Resource.new(client: @s3_client)
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

  def simple_post_policy(key, content_type)
    debugger()
    signer = Aws::S3::Presigner.new(client: @s3_client)

    url = signer.presigned_url(
      :put_object,
      bucket: ENV.fetch('S3_BUCKET_NAME'),
      key: key,
      acl: 'private',
      content_type: content_type,
      expires_in: 900 # 15 minutes
    )
    {
      url: url,
      headers: {
        'Content-Type' => content_type,
        'x-amz-acl' => 'private'
      }
    }
  end

  def initiate_multipart(key_prefix, content_type)
    debugger()
    key = "#{key_prefix}/#{SecureRandom.uuid}"
    resp = @s3_client.create_multipart_upload(
      bucket: bucket,
      key: key,
      content_type: content_type,
      acl: 'private'
    )
    { upload_id: resp.upload_id, key: key, part_size: 10.megabytes }
  end

  def complete_multipart_upload(key, upload_id, parts)
    @s3_client.complete_multipart_upload(key: key,
                                         upload_id: upload_id,
                                         multipart_upload: { parts: parts })
    "https://#{@bucket}.s3.amazonaws.com/#{key}"
  end

  private

    def find_file(prefix: INPUT_PREFIX)
      key = "#{prefix}#{@object_key}"
      obj = @bucket.object(key)
      obj.exists? ? obj : nil
    end
end
