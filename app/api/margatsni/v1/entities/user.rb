# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class User < Grape::Entity
        expose :id
        expose :username
        expose :email
        expose :bio
        expose :image do |instance|
          instance.image&.file_data_url
        end
      end
    end
  end
end
