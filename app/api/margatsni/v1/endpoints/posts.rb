# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Posts < Margatsni::V1::BaseV1
        helpers do
          def represent_post(post)
            present :post, post, with: Margatsni::V1::Entities::Post
          end
        end

        namespace :posts do
          desc 'Return list of posts'
          get do
            post = Post.all
            present post, with: Margatsni::V1::Entities::Post
          end

          desc 'Return a specific post'
          params do
            requires :id, type: String
          end
          get :id do
            post = Post.find(params[:id])
            represent_post(post)
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end

          before do
            current_user
          end

          desc 'Create new post'
          params do
            requires :body, type: String
          end
          post :new do
            post = current_user.posts.create(declared(params))

            represent_post(post)
          end

          desc 'Update a post'
          params do
            requires :id, type: String
            requires :body, type: String
          end
          put :id do
            current_user.posts.find(params[:id]).update(body: params[:body])
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end

          desc 'Delete a post'
          params do
            requires :id, type: String
          end
          delete :id do
            current_user.posts.find(params[:id]).destroy
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end
        end
      end
    end
  end
end
