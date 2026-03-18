# frozen_string_literal: true

module OmniAuthHelpers
  AUTHORIZED_USERS_ROLE = 'test-authorized-users-role'
  ADMIN_USERS_ROLE = 'test-admin-users-role'

  def with_mock_auth_env(&)
    ClimateControl.modify(
      AUTHORIZED_USERS_ROLE: AUTHORIZED_USERS_ROLE,
      ADMIN_USERS_ROLE: ADMIN_USERS_ROLE, &
    )
  end

  def mock_azure_login(email:, admin: false)
    roles = [AUTHORIZED_USERS_ROLE]
    roles << ADMIN_USERS_ROLE if admin

    OmniAuth.config.mock_auth[:azure_oauth] = OmniAuth::AuthHash.new(
      provider: 'azure_oauth',
      uid: SecureRandom.uuid,
      info: {
        email: email
      },
      extra: {
        raw_info: {
          roles: roles
        }
      }
    )
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers
end
