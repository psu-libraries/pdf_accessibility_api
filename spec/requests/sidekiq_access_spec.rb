# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sidekiq Access Constraint' do
  it 'allows access for authorized user' do
    get '/sidekiq', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'test1@psu.edu' }

    expect(response).to have_http_status(:ok).or have_http_status(:found)
  end

  it 'redirects access for unauthorized user' do
    get '/sidekiq', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'unauthorized@example.com' }

    expect(request.path).to eq '/unauthenticated'
    expect(response).to have_http_status :redirect
    expect(response.body).to include 'Redirecting to unauthorized page'
  end

  it 'redirects access when header is missing' do
    get '/sidekiq'

    expect(request.path).to eq '/unauthenticated'
    expect(response).to have_http_status :redirect
    expect(response.body).to include 'Redirecting to unauthorized page'
  end
end
