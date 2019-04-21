# frozen_string_literal: true

require 'grape-swagger'
require_relative './validators/length'

module Margatsni
  module V1
    class BaseV1 < Margatsni::ApiBase
      extend ActionView::Helpers::TranslationHelper
      prefix 'api'
      version 'v1', using: :path
      format :json
      default_format :json

      helpers Margatsni::V1::Helpers::ErrorFormatter
      helpers Margatsni::V1::Helpers::Auth

      error_formatter :json, Margatsni::V1::Formatters::ErrorFormatter

      mount Margatsni::V1::Endpoints::Users
      mount Margatsni::V1::Endpoints::Posts
      mount Margatsni::V1::Endpoints::Comments
      mount Margatsni::V1::Endpoints::Followers
      mount Margatsni::V1::Endpoints::Likes, with: { likeable: 'posts' }
      mount Margatsni::V1::Endpoints::Likes, with: { likeable: 'comments' }

      add_swagger_documentation api_version: 'v1', hide_documentation_path: true
    end
  end
end
