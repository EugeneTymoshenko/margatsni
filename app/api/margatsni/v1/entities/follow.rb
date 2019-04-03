# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Follow < Grape::Entity
        expose :follower_id
        expose :user_id
      end
    end
  end
end
