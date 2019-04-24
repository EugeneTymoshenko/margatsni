# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Followers < Margatsni::V1::BaseV1
        namespace 'users/:user_id' do
          namespace :following do
            desc 'return list of following users'
            get do
              following = User.find_by(id: params[:user_id]).following
              not_found!(key: :user) unless following

              present following, with: Margatsni::V1::Entities::User
            end

            before do
              authenticate_request!
            end

            desc 'subscribe'
            post do
              following_user = current_user.following_users.find_by(follower_id: params[:user_id])
              error!({ user: ['already followed'] }, 406) if following_user

              present :status, current_user.following_users.create(follower_id: params[:user_id]).present?
            end

            desc 'unsubscribe'
            delete do
              following_user = current_user.following_users.find_by(follower_id: params[:user_id])
              not_found!(key: :user) unless following_user

              present :status, following_user.destroy.present?
            end
          end

          namespace :followers do
            get do
              followers = User.find_by(id: params[:user_id]).followers
              not_found!(key: :user) unless followers

              present followers, with: Margatsni::V1::Entities::User
            end
          end
        end
      end
    end
  end
end
