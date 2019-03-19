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

          def comment
            @comment ||= Comment.find_by(user_id: current_user.id, id: params[:comment_id])
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
              current_user
            end

            desc 'Create a comment'
            params do
              requires :body, type: String, allow_blank: false
              optional :comment_id, type: Integer
            end
            post do
              owner = params[:comment_id] ? comment : post
              comment = owner.comments.new(body: params[:body], user_id: current_user.id)
              if comment.save
                represent_comment(comment)
              else
                present :errors, comment.errors.full_messages
              end
            end

            desc 'Update a comment'
            params do
              requires :comment_id, type: Integer, allow_blank: false
              requires :body, type: String, allow_blank: false, length: 200
            end
            put :id do
              error!('error!', 403) unless comment.update(body: params[:body])

              represent_comment(comment)
            end

            desc 'Delete a comment'
            params do
              requires :comment_id, type: Integer, allow_blank: false
            end
            delete :id do
              present :status, comment.destroy.present?
            end
          end
        end
      end
    end
  end
end
