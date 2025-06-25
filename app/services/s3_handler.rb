require 'aws-sdk-s3'

class S3Handler
  INPUT_PREFIX = 'pdf/'
  OUTPUT_PREFIX = 'result/'

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
    bucket.object(key).upload_file(local_path)
    key
  end

  def find_file(prefix: INPUT_PREFIX)
    compliant_key = "#{OUPUT_PREFIX}COMPLIANT_#{@object_key}"
    obj = @bucket.object(compliant_key)
    obj.exists? ? obj : nil
  end

  def presigned_url_for_result(expires_in: 3600)
    obj = find_result_file(@object_key)
    return nil unless obj

    obj.presigned_url(:get, expires_in: expires_in)
  end

  def delete_file(prefix: INPUT_PREFIX)
    obj = find_file(prefix: prefix)
    return false unless obj

    obj.delete
    true
  end
end