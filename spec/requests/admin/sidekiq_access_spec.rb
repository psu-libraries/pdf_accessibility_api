# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sidekiq Access Constraint' do
  let(:gui_user) { create(:gui_user, email: 'email@example.com') }

  it 'allows access for admin user' do
    login_gui_user(gui_user, admin: true)
    get '/sidekiq'

    expect(response).to have_http_status(:ok).or have_http_status(:found)
  end

  it 'denies access for non-admin user' do
    login_gui_user(gui_user, admin: false)
    get '/sidekiq'

    expect(request.path).to eq '/sidekiq'
    expect(response).to have_http_status :unauthorized
    expect(response.body).to include 'Unauthorized'
  end
end
