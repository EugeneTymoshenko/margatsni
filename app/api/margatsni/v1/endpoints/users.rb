# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Users < Margatsni::V1::BaseV1
        helpers do
          def represent_user_with_token(user)
            present :token, ::TokenProvider.issue_token(user_id: user.id)
            present :user, user, with: Margatsni::V1::Entities::User
          end
        end

        namespace :users do
          desc 'register a user'
          params do
            requires :username, type: String
            requires :email, type: String, regexp: User::EMAIL_REGEXP
            requires :password, type: String
          end
          post :registration do
            user = User.new(declared(params))
            error!('Username or email already taken!', 406) unless user.save

            represent_user_with_token(user)
          end

          desc 'user login'
          params do
            requires :email, type: String, regexp: User::EMAIL_REGEXP
            requires :password, type: String
          end
          post :login do
            user = authenticate_user!
            error!('Invalid email/password combination', 401) unless user

            represent_user_with_token(user)
          end
        end
      end
    end
  end
end
