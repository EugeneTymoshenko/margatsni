# frozen_string_literal: true

module Margatsni
  module V1
    module Helpers
      module Auth
        def current_user
          @current_user ||= authenticate_request!
        end

        def authenticate_user!
          user = User.authenticate(params[:email], params[:password])
          return error!('Unauthorized', 401) unless user

          user
        end

        private

        def authenticate_request!
          payload, _header = validate_token!
          @current_user = User.find_by(id: payload['user_id'])
          error!('No such user', 401) unless @current_user

          @current_user
        end

        def validate_token!
          TokenProvider.valid?(token)
        rescue JWT::VerificationError, JWT::DecodeError
          error!('Invalid token', 401)
        end

        def token
          request.headers['Authorization']&.split(' ')&.last
        end
      end
    end
  end
end
