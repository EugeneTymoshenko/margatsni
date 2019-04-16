# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Comments < Margatsni::V1::BaseV1
        helpers do
          attr_reader :post, :comment

          def represent_comment(comment)
            present :comment, comment, with: Margatsni::V1::Entities::Comment, except: %i[nested_comments]
          end

          def find_post!
            @post ||= Post.find_by(id: params[:post_id])
            @post || error!('Post not found', 404)
          end

          def find_comment!(scope = {})
            scope[:id] = params[:comment_id]
            @comment ||= Comment.find_by(scope)
            @comment || error!('Comment not found', 404)
          end
        end

        namespace 'posts/:post_id' do
          resources :comments do
            desc 'Get all comments for a specific post'
            params do
              optional :page, type: Integer
              optional :per_page, type: Integer
            end
            get do
              find_post!
              comments = post.comments.page(params[:page]).per(params[:per_page])

              present :page, comments.current_page
              present :per_page, comments.current_per_page
              present :comments, comments, with: Margatsni::V1::Entities::Comment
            end

            before do
              authenticate_request!
            end

            desc 'Create a comment for post'
            params do
              requires :body, type: String, allow_blank: false, length: 300
            end
            post do
              find_post!
              comment = post.comments.build(body: params[:body], user: current_user)
              error!(comment.errors.full_messages) unless comment.save

              represent_comment(comment)
            end

            route_param :comment_id do
              desc 'Update a comment'
              params do
                requires :body, type: String, allow_blank: false, length: 300
              end
              put do
                find_comment!(user: current_user)
                comment.update(declared(params))

                represent_comment(comment)
              end

              desc 'Delete a comment'
              delete do
                find_comment!(user: current_user)

                present :status, comment.destroy.present?
              end

              desc 'Create a nested comment'
              params do
                requires :body, type: String, allow_blank: false, length: 300
              end
              post do
                find_comment!
                nested_comment = comment.comments.build(body: params[:body], user: current_user)
                error!(nested_comment.errors.full_messages) unless nested_comment.save

                represent_comment(nested_comment)
              end
            end
          end
        end
      end
    end
  end
end
