# frozen_string_literal: true

module Margatsni
  class ApiBase < Grape::API
    default_format :json
    mount Margatsni::V1::BaseV1
  end
end
