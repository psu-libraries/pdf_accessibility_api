# frozen_string_literal: true

class BaseApiController < ActionController::API
  def authenticate_request!
    header_token = request.headers['HTTP_X_API_KEY']

    # Initial set-up for development – a single token for all developers
    # In the future, we'll want to store different tokens for different clients in the database.
    if header_token == ENV.fetch('API_BEARER_TOKEN')
      true
    else
      render json: { message: 'Not authorized', code: 401 }, status: :unauthorized
    end
  end
end
