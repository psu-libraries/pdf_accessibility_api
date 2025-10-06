# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Warden Http Header Authentication' do
  context 'when allowlisted user' do
    it 'returns 200 status' do
      get '/pdf_jobs/new', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'test1@psu.edu' }
      expect(request.path).to eq '/pdf_jobs/new'
      expect(response).to have_http_status :ok
      expect(response.body).to include I18n.t('heading')
    end
  end

  context 'when user is not allowlisted' do
    it 'returns 302 status and redirects to unauthorized page' do
      get '/pdf_jobs/new', headers: { 'HTTP_X_AUTH_REQUEST_EMAIL' => 'test2@psu.edu' }
      expect(request.path).to eq '/unauthenticated'
      expect(response).to have_http_status :redirect
      expect(response.body).to include 'Redirecting to unauthorized page'
    end
  end
end
