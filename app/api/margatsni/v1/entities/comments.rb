# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Comments < Margatsni::V1::Entities::Comment
        expose :nested_comments do |instance|
          Margatsni::V1::Entities::Comment.represent(instance.comments)
        end
      end
    end
  end
end
