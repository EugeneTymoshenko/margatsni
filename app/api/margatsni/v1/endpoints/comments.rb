# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Comments < Margatsni::V1::BaseV1
        helpers do
          def represent_comment(comment)
            present :comment, comment, with: Margatsni::V1::Entities::Comment
          end

          def post
            @post ||= Post.find_by(id: params[:post_id])
            @post || error!('Post not found', 404)
          end

          def comment(scope = {})
            scope[:id] = params[:comment_id]
            @comment ||= Comment.find_by(scope)
            @comment || error!('Comment not found', 404)
          end
        end

        namespace 'posts/:post_id' do
          resources :comments do
            desc 'Get all comments for a specific post'
            get do
              present :comments, post.comments, with: Margatsni::V1::Entities::Comments
            end

            before do
              authenticate_request!
            end

            desc 'Create a comment'
            params do
              requires :body, type: String, allow_blank: false
              optional :comment_id, type: Integer, allow_blank: false
            end
            post do
              owner = params[:comment_id] ? comment : post
              comment = owner.comments.build(body: params[:body], user_id: current_user.id)
              error!(comment.errors.full_messages) unless comment.save

              represent_comment(comment)
            end

            route_param :comment_id do
              desc 'Update a comment'
              params do
                requires :body, type: String, allow_blank: false, length: 200
              end
              put do
                comment(user_id: current_user.id).update(declared(params))

                represent_comment(comment)
              end

              desc 'Delete a comment'
              delete do
                present :status, comment(user_id: current_user.id).destroy.present?
              end
            end
          end
        end
      end
    end
  end
end
