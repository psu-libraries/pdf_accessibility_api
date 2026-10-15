# frozen_string_literal: true

module SeaweedFsEnvironmentHelper
  def with_seaweedfs_env(&)
    ClimateControl.modify({
                            S3_ENDPOINT: 'http://seaweedfs:8333',
                            S3_BUCKET_NAME: ENV.fetch('S3_BUCKET_NAME', 'pdf-accessibility-api'),
                            AWS_ACCESS_KEY_ID: ENV.fetch('AWS_ACCESS_KEY_ID', 'pdf_accessibility_api'),
                            AWS_SECRET_ACCESS_KEY: ENV.fetch('AWS_SECRET_ACCESS_KEY', 'pdf_accessibility_api'),
                            AWS_REGION: 'us-east-1'
                          }, &)
  end
end
