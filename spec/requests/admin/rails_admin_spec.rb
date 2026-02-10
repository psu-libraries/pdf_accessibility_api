# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RailsAdmin access' do
  let(:admin_email) { 'test1@psu.edu' }
  let(:non_admin_email) { 'notadmin@example.com' }
  let(:admin_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => admin_email } }
  let(:non_admin_headers) { { 'HTTP_X_AUTH_REQUEST_EMAIL' => non_admin_email } }

  before do
    create(:gui_user, email: admin_email)
    create(:api_user)
  end

  context 'when user is an admin' do
    it 'allows access to the dashboard' do
      get '/admin', headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to GuiUser model' do
      get '/admin/gui_user', headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to ApiUser model' do
      get '/admin/api_user', headers: admin_headers
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to Job model' do
      get '/admin/job', headers: admin_headers
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when user is not an admin' do
    it 'blocks access to dashboard' do
      get '/admin', headers: non_admin_headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when unauthenticated' do
    it 'blocks access' do
      get '/admin'
      expect(response).to have_http_status(:forbidden)
    end
  end
end
