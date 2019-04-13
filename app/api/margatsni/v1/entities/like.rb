# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Like < Grape::Entity
        expose :id
        expose :user_id
      end
    end
  end
end
