# frozen_string_literal: true

module Margatsni
  module V1
    module Helpers
      module Auth
        attr_accessor :current_user

        def authenticate_user!
          user = User.authenticate(params[:email], params[:password])
          return error!('Unauthorized', 401) unless user

          user
        end

        def authenticate_request!
          payload, _header = validate_token!
          self.current_user = User.find_by(id: payload['user_id'])
          error!('No such user', 401) unless current_user
        end

        private

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
