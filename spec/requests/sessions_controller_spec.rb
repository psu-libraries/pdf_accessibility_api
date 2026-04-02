# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SessionsController' do
  describe 'GET /pdf_jobs/new' do
    it 'renders the auto-login page for unauthenticated users' do
      get '/pdf_jobs/new'

      expect(response).to have_http_status :ok
      expect(response.body).to include('id="auto_login"')
      expect(response.body).to include('action="/auth/azure_oauth"')
    end
  end

  describe 'GET /auth/azure_oauth/callback' do
    it 'logs in authorized users and redirects to root' do
      user = create(:gui_user, email: 'test1@psu.edu')

      login_gui_user(user, admin: false)

      expect(response).to redirect_to(root_path)
      get '/pdf_jobs/new'
      expect(response).to have_http_status :ok
      expect(response.body).to include(I18n.t('heading'))
    end

    it 'returns forbidden for users outside the authorized role' do
      with_mock_auth_env do
        OmniAuth.config.mock_auth[:azure_oauth] = OmniAuth::AuthHash.new(
          provider: 'azure_oauth',
          uid: SecureRandom.uuid,
          extra: {
            raw_info: {
              upn: 'not-authorized@example.com',
              roles: []
            }
          }
        )

        get '/auth/azure_oauth/callback'
      end

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Forbidden')
    end
  end

  describe 'GET /auth/failure' do
    it 'returns unauthorized with a readable error message' do
      get '/auth/failure', params: { message: 'access_denied' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include('Authentication failed: Access denied')
    end
  end

  describe 'DELETE /logout' do
    it 'resets the session and redirects to root' do
      user = create(:gui_user, email: 'test1@psu.edu')
      login_gui_user(user, admin: false)

      delete '/logout'

      expect(response).to redirect_to(root_path)

      # If session is reset, user should see auto-login page again
      get '/pdf_jobs/new'
      expect(response).to have_http_status :ok
      expect(response.body).to include('id="auto_login"')
      expect(response.body).to include('action="/auth/azure_oauth"')
    end
  end
end
