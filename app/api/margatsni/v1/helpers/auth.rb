# frozen_string_literal: true

module Margatsni
  module V1
    module Helpers
      module Auth
        def validate_token!
          TokenProvider.valid?(token)
        rescue JWT::VerificationError, JWT::DecodeError
          error!('Unauthorized', 401)
        end

        def authenticate_request!
          payload, _header = validate_token!
          @current_user = User.find_by(id: payload['user_id'])
        # rescue
        #   error!('Unauthorized', 401)
        end

        def authenticate_user!
          user = User.authenticate(params[:email], params[:password])
          return error!('Unauthorized', 401) unless user

          present :token, ::TokenProvider.issue_token(user_id: user.id)
        end

        def current_user
          @current_user ||= authenticate_user!
        end

        def token
          request.headers['Authorization'].split(' ').last
        end
      end
    end
  end
end
