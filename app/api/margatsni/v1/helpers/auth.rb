# frozen_string_literal: true

module Margatsni
  module V1
    module Helpers
      module Auth
        attr_accessor :current_user

        def authenticate_user!
          user = User.authenticate(params[:email], params[:password])
          error!({ credentials: ['are invalid'] }, 401) unless user

          user
        end

        def authenticate_request!
          payload, _header = validate_token!
          self.current_user = User.find_by(id: payload['user_id'])
          not_found!(key: :user) unless current_user
        end

        def public_endpoint_authentication
          return unless token_present?

          authenticate_request!
        end

        private

        def token_present?
          request.headers['Authorization'].present?
        end

        def validate_token!
          TokenProvider.valid?(token)
        rescue JWT::VerificationError, JWT::DecodeError
          error!({ token: ['is invalid or expired'] }, 401)
        end

        def token
          request.headers['Authorization']&.split(' ')&.last
        end
      end
    end
  end
end
