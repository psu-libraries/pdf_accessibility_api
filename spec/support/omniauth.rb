# frozen_string_literal: true

module OmniAuthHelpers
  def mock_azure_login(email:, admin: false)
    groups = [ENV.fetch('AUTHORIZED_USERS_GROUP', nil)]
    groups << ENV.fetch('ADMIN_USERS_GROUP', nil) if admin

    OmniAuth.config.mock_auth[:azure_oauth] = OmniAuth::AuthHash.new(
      provider: 'azure_oauth',
      uid: SecureRandom.uuid,
      info: {
        email: email
      },
      extra: {
        raw_info: {
          groups: groups
        }
      }
    )
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers
end
