# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Comments < Margatsni::V1::BaseV1
        helpers do
          def represent_comment(comment)
            present :comment, comment, with: Margatsni::V1::Entities::Comment
          end
        end

        namespace 'posts/:post_id' do
          resources :comments do

            before do
              current_user
            end

            desc 'Create a comment'
            params do
              requires :body, type: String, allow_blank: false
            end
            post do
              post = Post.find(params[:post_id])
              comment = post.comments.new(body: params[:body])
              comment.user_id = current_user.id
              comment.save

              represent_comment(comment)
            end

            desc 'Update a comment'
            params do
              requires :id, type: Integer, allow_blank: false
              requires :body, type: String, allow_blank: false, length: 200
            end
            put ':id' do
              post = Post.find(params[:post_id])
              comment = post.comments.find(params[:id])
              if comment.user_id == current_user.id
              comment.update(body: params[:body])
              else
                error!('This comment is not yours', 403)
              end

              represent_comment(comment)
            end

            desc 'Delete a comment'
            params do
              requires :id, type: Integer, allow_blank: false
            end
            delete ':id' do
              post = Post.find(params[:post_id])
              comment = post.comments.find(params[:id])
              if comment.user_id == current_user.id
                present :status, !comment.destroy.nil?
              else
                error!('This comment is not yours', 403)
              end
            end
          end
        end
      end
    end
  end
end
