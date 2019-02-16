# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class User < Grape::Entity
        expose :username
        expose :email
        expose :token do |user|
          ::TokenProvider.issue_token(user_id: user.id)
        end
      end
    end
  end
end
