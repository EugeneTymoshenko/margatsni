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
            @tag || not_found!(key: :tag)
          end

          def find_user!
            @user ||= User.find_by(username: params[:username])
            @user || not_found!(key: :user)
          end
        end

        namespace :posts do
          namespace :tags do
            desc 'return list of tags'
            params do
              optional :page, type: Integer
              optional :per_page, type: Integer
              optional :name_query, type: String
            end
            get do
              tags = Tag.search_by_name(params[:name_query]).page(params[:page]).per(params[:per_page])

              present :total_pages, tags.total_pages
              present :page, tags.current_page
              present :per_page, tags.current_per_page
              present :tags, tags, with: Margatsni::V1::Entities::Tag
            end

            desc 'Return list of post with choosen hashtag'
            params do
              optional :page, type: Integer
              optional :per_page, type: Integer
            end
            get ':tag_name' do
              find_tag!
              posts = tag.posts.page(params[:page]).per(params[:per_page])

              represent_posts(posts)
            end
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
            post = Post.find_by(id: params[:post_id])
            not_found!(key: :post) unless post

            represent_post(post)
          end

          desc 'Create new post'
          params do
            requires :body, type: String, length: 500
            requires :image_attributes, type: Hash do
              optional :file_data, type: File, allow_blank: false
            end
          end
          post do
            authenticate_request!
            post = current_user.posts.build(declared(params, include_missing: false))
            error!(post.errors.messages, 422) unless post.save

            represent_post(post.reload)
          end

          route_param :post_id do
            desc 'Update a post'
            params do
              requires :body, type: String, length: 500
            end
            put do
              authenticate_request!
              post = current_user.posts.find_by(id: params[:post_id])
              not_found!(key: :post) unless post
              error!(post.errors.messages, 422) unless post.update(declared(params))

              represent_post(post)
            end

            desc 'Delete a post'
            delete do
              authenticate_request!
              post = current_user.posts.find_by(id: params[:post_id])
              not_found!(key: :post) unless post

              present :status, post.destroy.present?
            end
          end
        end
      end
    end
  end
end
