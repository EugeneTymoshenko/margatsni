# frozen_string_literal: true

module Margatsni
  module V1
    module Endpoints
      class Comments < Margatsni::V1::BaseV1
        helpers do
          attr_reader :post, :comment

          def represent_comment(comment)
            present :comment,
                    comment,
                    with: Margatsni::V1::Entities::Comment,
                    except: %i[nested_comments],
                    user: current_user
          end

          def find_post!
            @post ||= Post.find_by(id: params[:post_id])
            @post || not_found!(key: :post)
          end

          def find_comment!(scope = {})
            scope[:id] = params[:comment_id]
            @comment ||= Comment.find_by(scope)
            @comment || not_found!(key: :comment)
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
              public_endpoint_authentication
              find_post!
              comments = post.comments.order(id: :desc).page(params[:page]).per(params[:per_page])

              present :total_pages, comments.total_pages
              present :page, comments.current_page
              present :per_page, comments.current_per_page
              present :comments, comments, with: Margatsni::V1::Entities::Comment, user: current_user
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
              error!(comment.errors.messages) unless comment.save

              represent_comment(comment)
            end

            route_param :comment_id do
              desc 'Update a comment'
              params do
                requires :body, type: String, allow_blank: false, length: 300
              end
              put do
                find_post!
                find_comment!(user: current_user)
                comment.update(declared(params))

                represent_comment(comment)
              end

              desc 'Delete a comment'
              delete do
                find_post!
                find_comment!(user: current_user)

                present :status, comment.destroy.present?
              end

              desc 'Create a nested comment'
              params do
                requires :body, type: String, allow_blank: false, length: 300
              end
              post do
                find_post!
                find_comment!
                nested_comment = comment.comments.build(body: params[:body], user: current_user)
                error!(nested_comment.errors.messages) unless nested_comment.save

                represent_comment(nested_comment)
              end
            end
          end
        end
      end
    end
  end
end
