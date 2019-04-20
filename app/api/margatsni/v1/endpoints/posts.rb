# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Posts < Margatsni::V1::BaseV1
        helpers do
          attr_reader :user, :tag

          def represent_post(post)
            present :post, post, with: Margatsni::V1::Entities::Post, user: current_user
          end

          def represent_posts(posts)
            present :total_pages, posts.total_pages
            present :page, posts.current_page
            present :per_page, posts.current_per_page
            present :posts, posts, with: Margatsni::V1::Entities::Post, user: current_user
          end

          def find_tag!
            @tag ||= Tag.find_by(name: params[:tag_name])
            @tag || error!('Tag not found!', 404)
          end

          def find_user!
            @user ||= User.find_by(username: params[:username])
            @user || error!('User not found!', 404)
          end
        end

        namespace :posts do
          desc 'Return list of post with choosen hashtag'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get 'tags/:tag_name' do
            find_tag!
            posts = tag.posts.page(params[:page]).per(params[:per_page])

            represent_posts(posts)
          end

          desc 'Return list of posts'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get do
            public_endpoint_authentication
            posts = Post.all.order(id: :desc).page(params[:page]).per(params[:per_page])

            represent_posts(posts)
          end

          desc 'Return list of posts for current user'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get :me do
            authenticate_request!
            posts = current_user.posts.order(id: :desc).page(params[:page]).per(params[:per_page])

            represent_posts(posts)
          end

          desc 'Return list of posts for specific user'
          params do
            optional :page, type: Integer
            optional :per_page, type: Integer
          end
          get 'user/:username' do
            public_endpoint_authentication
            find_user!
            posts = user.posts.order(id: :desc).page(params[:page]).per(params[:per_page])

            represent_posts(posts)
          end

          desc 'Return a specific post'
          get ':post_id' do
            public_endpoint_authentication
            post = Post.find(params[:post_id])

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

          route_param :post_id do
            desc 'Update a post'
            params do
              requires :body, type: String, length: 500
            end
            put do
              post = current_user.posts.find(params[:post_id])
              post.update(declared(params))

              represent_post(post)
            rescue ActiveRecord::RecordNotFound
              error!('Post not found!', 404)
            end

            desc 'Delete a post'
            delete do
              present :status, current_user.posts.find(params[:post_id]).destroy.present?
            rescue ActiveRecord::RecordNotFound
              error!('Post not found!', 404)
            end
          end
        end
      end
    end
  end
end
