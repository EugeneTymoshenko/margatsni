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
              find_post!
            when 'comments'
              find_comment!
            else
              error!({ likeable_type: ['is invalid'] }, 404)
            end
          end

          def find_post!
            @post ||= Post.find_by(id: params[:likeable_id])
            @post || not_found!(key: :post)
          end

          def find_comment!
            @comment ||= Comment.find_by(id: params[:likeable_id])
            @comment || not_found!(key: :comment)
          end

          def represent_owner
            present likeable_type.downcase.to_sym,
                    owner,
                    with: "Margatsni::V1::Entities::#{likeable_type}".constantize,
                    except: %i[nested_comments],
                    user: current_user
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
            error!({ like: ['already liked'] }, 422) if liked?
            like = owner.likes.build(user: current_user)
            error!(like.errors.messages) unless like.save

            represent_owner
          end

          desc "Delete like for #{configuration[:likeable]}"
          delete do
            error!({ like: ['cannot dislike'] }, 422) unless liked?

            present :status, owner.likes.where(user: current_user).destroy_all.present?
          end
        end
      end
    end
  end
end
