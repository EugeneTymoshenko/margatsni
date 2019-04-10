# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Followers < Margatsni::V1::BaseV1
        namespace 'users/:user_id' do
          namespace :following do
            desc 'return list of following users'
            get do
              following = User.find(params[:user_id]).following
              present following, with: Margatsni::V1::Entities::User
            rescue ActiveRecord::RecordNotFound
              error!('User not found!', 404)
            end

            before do
              authenticate_request!
            end

            desc 'subscribe'
            post do
              following_user = current_user.following_users.find_by(following_id: params[:user_id])
              error!('User already followed', 406) if following_user
              present :status, !current_user.following_users.create(following_id: params[:user_id]).present?
            end

            desc 'unsubscribe'
            delete do
              following_user = current_user.following_users.find_by(follower_id: params[:user_id])
              error!('User not found', 404) unless following_user
              present :status, !following_user.destroy.present?
            end
          end
        end

        namespace :followers do
          get do
            followers = User.find(params[:user_id]).followers
            present followers, with: Margatsni::V1::Entities::User
          rescue ActiveRecord::RecordNotFound
            error!('User not found!', 404)
          end
        end
      end
    end
  end
end
