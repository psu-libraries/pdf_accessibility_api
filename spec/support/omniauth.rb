# frozen_string_literal: true

module OmniAuthHelpers
  AUTHORIZED_USERS_GROUP = 'test-authorized-users-group'
  ADMIN_USERS_GROUP = 'test-admin-users-group'

  def with_mock_auth_env(&)
    ClimateControl.modify(
      AUTHORIZED_USERS_GROUP: AUTHORIZED_USERS_GROUP,
      ADMIN_USERS_GROUP: ADMIN_USERS_GROUP, &
    )
  end

  def mock_azure_login(email:, admin: false)
    groups = [AUTHORIZED_USERS_GROUP]
    groups << ADMIN_USERS_GROUP if admin

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
