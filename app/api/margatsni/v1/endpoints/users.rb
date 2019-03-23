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

          def represent_current_user(current_user)
            present :user, current_user, with: Margatsni::V1::Entities::User
          end
        end

        namespace :users do
          desc 'register a user'
          params do
            requires :username, type: String, allow_blank: false
            requires :email, type: String, regexp: User::EMAIL_REGEXP
            requires :password, type: String, allow_blank: false
          end
          post do
            user = User.new(declared(params))
            error!('Username or email already taken!', 406) unless user.save

            represent_user_with_token(user)
          end

          desc 'user login'
          params do
            requires :email, type: String, regexp: User::EMAIL_REGEXP
            requires :password, type: String, allow_blank: false
          end
          post :login do
            user = authenticate_user!
            error!('Invalid email/password combination', 401) unless user

            represent_user_with_token(user)
          end

          namespace :me do
            desc 'profile'
            get do
              represent_current_user(current_user)
            end

            desc 'edit user'
            params do
              optional :username, type: String, allow_blank: false
              optional :email, type: String, regexp: User::EMAIL_REGEXP
              optional :password, type: String, allow_blank: false
              optional :bio, type: String
            end
            put do
              current_user.update(declared(params))

              represent_current_user(current_user)
            end
          end
        end
      end
    end
  end
end
