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
              requires :file_data, type: File
            end
          end
          post do
            user = User.new(declared(params, include_missing: false))
            error!(user.errors.messages, 406) unless user.save

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
                requires :file_data, type: File
              end
            end
            put do
              current_user.update(declared(params))

              represent_current_user(current_user)
            end
          end

          namespace :following do
            desc 'return list of followed users'
            params do
              requires :user_id, type: Integer, allow_blank: false
            end
            get do
              followed = FollowerUser.where(user_id: params[:user_id])
              present followed, with: Margatsni::V1::Entities::Follow, except: [:user_id]
            end

            before do
              authenticate_request!
            end

            desc 'subscribe'
            params do
              requires :follower_id, type: Integer, allow_blank: false
            end
            post do
              followed = current_user.follower_users.find_by(follower_id: params[:follower_id])
              error!('User already followed', 406) if followed
              present :status, !current_user.follower_users.create(declared(params)).present?
            end

            desc 'unsubscribe'
            params do
              requires :follower_id, type: Integer, allow_blank: false
            end
            delete do
              followed = current_user.follower_users.find_by(follower_id: params[:follower_id])
              error!('User not found', 404) unless followed
              present :status, !followed.destroy.present?
            end
          end

          namespace :followers do
            desc 'return list of followers users'
            params do
              requires :follower_id, type: Integer, allow_blank: false
            end
            get do
              followers = FollowerUser.where(follower_id: params[:follower_id])
              present followers, with: Margatsni::V1::Entities::Follow, except: [:follower_id]
            end
          end

          desc 'get list of users'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get :people do
            users = User.all.page(params[:page]).per(params[:per_page])

            present :page, users.current_page
            present :per_page, users.current_per_page
            present :users, users, with: Margatsni::V1::Entities::User, only: [:username]
          end
        end
      end
    end
  end
end
