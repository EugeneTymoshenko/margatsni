# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Post < Grape::Entity
        format_with(:european_timestamp) do |date|
          date.strftime('%d.%m.%y %H:%M')
        end

        expose :id
        expose :body
        expose :image do |instance|
          instance.image&.file_data_url
        end
        expose :comments do |instance|
          Margatsni::V1::Entities::Comment.represent(
            instance.comments.last(3),
            user: options[:user]
          )
        end
        expose :likes_count do |instance|
          instance.likes.count
        end
        expose :liked do |instance, options|
          instance.likes.where(user: options[:user]).exists?
        end
        expose :user do |instance|
          Margatsni::V1::Entities::User.represent(
            instance.user,
            except: %i[email bio]
          )
        end
        expose :tags, with: Margatsni::V1::Entities::Tag

        with_options(format_with: :european_timestamp) do
          expose :created_at
        end
      end
    end
  end
end
