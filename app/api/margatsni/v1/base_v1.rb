# frozen_string_literal: true

require 'grape-swagger'

module Margatsni
  module V1
    class BaseV1 < Margatsni::ApiBase
      extend ActionView::Helpers::TranslationHelper
      prefix 'api'
      version 'v1', using: :path
      format :json

      helpers Margatsni::V1::Helpers::Auth
      mount Margatsni::V1::Endpoints::Users
      mount Margatsni::V1::Endpoints::Posts
      add_swagger_documentation api_version: 'v1', hide_documentation_path: true
    end
  end
end
