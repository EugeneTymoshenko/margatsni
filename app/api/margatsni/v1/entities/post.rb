# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Post < Grape::Entity
        expose :id
        expose :user_id
        expose :body
        expose :created_at
      end
    end
  end
end
