# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RailsAdmin access' do
  let(:admin_email) { 'test1@psu.edu' }
  let(:non_admin_email) { 'notadmin@example.com' }
  let!(:admin_user) { create(:gui_user, email: admin_email) }
  let!(:non_admin_user) { create(:gui_user, email: non_admin_email) }

  context 'when user is an admin' do
    before do
      login_as(admin_user)
    end

    it 'allows access to the dashboard' do
      get '/admin'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to GuiUser model' do
      get '/admin/gui_user'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to ApiUser model' do
      get '/admin/api_user'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to Job model' do
      get '/admin/job'
      expect(response).to have_http_status(:ok)
    end

    it 'allows access to Unit model' do
      get '/admin/unit'
      expect(response).to have_http_status(:ok)
    end

    it 'allows POST to GuiUser new action' do
      post '/admin/gui_user/new',
           params: { gui_user: { email: 'new_admin_test_user@psu.edu' } }

      expect(response).not_to have_http_status(:forbidden)
    end

    it 'allows POST to Unit index action' do
      post '/admin/unit', params: { query: 'Test' }

      expect(response).not_to have_http_status(:forbidden)
    end
  end

  context 'when user is not an admin' do
    before do
      login_as(non_admin_user)
    end

    it 'blocks access to dashboard' do
      get '/admin'
      expect(response).to have_http_status(:forbidden)
    end

    it 'blocks POST to GuiUser new action' do
      post '/admin/gui_user/new',
           params: { gui_user: { email: 'blocked_user@psu.edu' } }

      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'when unauthenticated' do
    it 'blocks access' do
      get '/admin'
      expect(response).to have_http_status(:forbidden)
    end

    it 'blocks POST access' do
      post '/admin/gui_user/new', params: { gui_user: { email: 'anonymous_user@psu.edu' } }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
