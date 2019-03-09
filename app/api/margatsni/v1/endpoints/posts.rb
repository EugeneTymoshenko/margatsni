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
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get do
            posts = Post.all.page(params[:page]).per(params[:per_page])
            present :page, posts.current_page
            present :per_page, posts.current_per_page
            present :posts, posts, with: Margatsni::V1::Entities::Post
          end

          desc 'Return a specific post'
          params do
            requires :id, type: Integer, allow_blank: false
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
            requires :body, type: String, length: 500
          end
          post :new do
            post = current_user.posts.create(declared(params))

            represent_post(post)
          end

          desc 'Update a post'
          params do
            requires :id, type: Integer
            requires :body, type: String, length: 500
          end
          put :id do
            post = current_user.posts.find(params[:id])
            post.update(body: params[:body])

            represent_post(post)
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end

          desc 'Delete a post'
          params do
            requires :id, type: Integer, allow_blank: false
          end
          delete :id do
            present :status, !current_user.posts.find(params[:id]).destroy.nil?
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end
        end
      end
    end
  end
end
