# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class User < Grape::Entity
        expose :id
        expose :username
        expose :email
        expose :bio
      end
    end
  end
end
