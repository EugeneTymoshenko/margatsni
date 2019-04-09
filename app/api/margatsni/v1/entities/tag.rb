# frozen_string_literal: true

module Margatsni
  module V1
    module Entities
      class Tag < Grape::Entity
        expose :name
      end
    end
  end
end
