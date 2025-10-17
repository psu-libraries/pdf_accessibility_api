# frozen_string_literal: true

module MinioEnvironmentHelper
  def with_minio_env(&)
    ClimateControl.modify({
                            S3_ENDPOINT: 'http://minio:9000',
                            S3_BUCKET_NAME: 'pdf_accessibility_api',
                            AWS_ACCESS_KEY_ID: 'pdf_accessibility_api',
                            AWS_SECRET_ACCESS_KEY: 'pdf_accessibility_api',
                            AWS_REGION: 'us-east-1'
                          }, &)
  end
end
