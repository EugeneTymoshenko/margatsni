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
            requires :email, type: String, regexp: User::EMAIL_REGEXP, allow_blank: false
            requires :password, type: String, allow_blank: false
            optional :image_attributes, type: Hash do
              requires :file_data, type: File, allow_blank: false
            end
          end
          post do
            user = User.new(declared(params, include_missing: false))
            error!(user.errors.full_messages, 422) unless user.save

            represent_user_with_token(user.reload)
          end

          desc 'user login'
          params do
            requires :email, type: String, regexp: User::EMAIL_REGEXP, allow_blank: false
            requires :password, type: String, allow_blank: false
          end
          post :login do
            user = authenticate_user!
            error!('Invalid email/password combination', 401) unless user

            represent_user_with_token(user)
          end

          desc 'get list of users'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
            optional :username, type: String, allow_blank: false
          end
          get do
            users = User.all.page(params[:page]).per(params[:per_page])
            find_user = users.sea

            present :page, users.current_page
            present :per_page, users.current_per_page
            present :users, users, with: Margatsni::V1::Entities::User, only: %i[username image]
            present :users, find_user, with: Margatsni::V1::Entities::User, only: %i[username image]
          end

          namespace :me do
            before do
              authenticate_request!
            end

            desc 'profile'
            get do
              represent_current_user(current_user)
            end

            desc 'edit user'
            params do
              optional :username, type: String, allow_blank: false
              optional :email, type: String, regexp: User::EMAIL_REGEXP, allow_blank: false
              optional :password, type: String, allow_blank: false
              optional :bio, type: String, length: 300
              optional :image_attributes, type: Hash do
                requires :file_data, type: File, allow_blank: false
              end
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
