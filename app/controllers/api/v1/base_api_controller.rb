# frozen_string_literal: true

module API::V1
  class BaseAPIController < ActionController::API
    before_action :authenticate_request!

    private

      attr_reader :current_api_user

      def authenticate_request!
        @current_api_user = APIUser.find_by(api_key: api_key_header)

        if current_api_user
          true
        else
          render json: { message: 'Not authorized', code: 401 }, status: :unauthorized
        end
      end

      def api_key_header
        request.headers['HTTP_X_API_KEY']
      end
  end
end
