# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Likes < Margatsni::V1::BaseV1
        helpers do
          def liked?
            Like.where(
              user: current_user,
              likeable_type: likeable_type,
              likeable_id: params[:likeable_id]
            ).exists?
          end

          def owner
            case params[:likeable]
            when 'posts'
              post
            when 'comments'
              comment
            else
              error!('Wrong route!', 404)
            end
          end

          def post
            @post ||= Post.find_by(id: params[:likeable_id])
            @post || error!('Post not found', 404)
          end

          def comment
            @comment ||= Comment.find_by(id: params[:likeable_id])
            @comment || error!('Comment not found', 404)
          end

          def represent_owner
            present likeable_type.downcase.to_sym, owner, with: "Margatsni::V1::Entities::#{likeable_type}".constantize
          end

          private

          def likeable_type
            params[:likeable].singularize.capitalize
          end
        end

        namespace ':likeable/:likeable_id/likes' do
          desc "Get likes for #{configuration[:likeable]}"
          get do
            entity = owner.likes

            present :likes, entity, with: Margatsni::V1::Entities::Like
          end

          before do
            authenticate_request!
          end

          desc "Like #{configuration[:likeable]}"
          post do
            error!('You can\'t like more than once', 422) if liked?
            like = owner.likes.build(user: current_user)
            error!(like.errors.messages) unless like.save

            represent_owner
          end

          desc "Delete like for #{configuration[:likeable]}"
          delete do
            error!('Cannot dislike', 422) unless liked?

            present :status, owner.likes.where(user: current_user).destroy_all.present?
          end
        end
      end
    end
  end
end
