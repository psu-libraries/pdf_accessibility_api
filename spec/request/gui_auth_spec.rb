# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Warden Http Header Authentication', type: :request do
  context 'when allowlisted user' do
    it 'returns 200 status' do
      pending('routes are not fully implemented yet')
      get 'gui/uploads', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'test1@psu.edu' }
      expect(request.path).to eq '/'
      expect(response).to have_http_status :ok
      expect(response.body).to include 'Search'
    end
  end

  context 'when user is not allowlisted' do
    it 'returns 401 status and redirects to 401 page' do
      pending('routes are not fully implemented yet')
      get '/', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'test2@psu.edu' }
      expect(request.path).to eq '/unauthenticated'
      expect(response).to have_http_status :unauthorized
      expect(response.body).to include 'Unauthorized'
    end
  end
end
