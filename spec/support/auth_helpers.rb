module AuthHelpers
  def login_gui_user(user, admin: false)
    mock_azure_login(email: user.email, admin: admin)

    if respond_to?(:visit)
      visit "/auth/azure_oauth"
    else
      get "/auth/azure_oauth/callback"
    end
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :feature
end