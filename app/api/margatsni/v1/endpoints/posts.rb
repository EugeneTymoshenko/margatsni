# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Posts < Margatsni::V1::BaseV1
        mount Likes, with: { likeable: 'posts' }

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
          get ':id' do
            post = Post.find(params[:id])

            represent_post(post)
          rescue ActiveRecord::RecordNotFound
            error!('Post not found!', 404)
          end

          before do
            authenticate_request!
          end

          desc 'Create new post'
          params do
            requires :body, type: String, length: 500
            requires :image_attributes, type: Hash do
              requires :file_data, type: File, allow_blank: false
            end
          end
          post do
            post = current_user.posts.build(declared(params, include_missing: false))
            error!(post.errors.full_messages, 422) unless post.save

            represent_post(post.reload)
          end

          route_param :id do
            desc 'Update a post'
            params do
              requires :body, type: String, length: 500
            end
            put do
              post = current_user.posts.find(params[:id])
              post.update(declared(params))

              represent_post(post)
            rescue ActiveRecord::RecordNotFound
              error!('Post not found!', 404)
            end

            desc 'Delete a post'
            delete do
              present :status, !current_user.posts.find(params[:id]).destroy.nil?
            rescue ActiveRecord::RecordNotFound
              error!('Post not found!', 404)
            end
          end
        end
      end
    end
  end
end
