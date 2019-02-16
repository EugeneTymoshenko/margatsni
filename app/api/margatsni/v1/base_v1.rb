require 'grape-swagger'

class Margatsni::V1::BaseV1 < Margatsni::ApiBase
  extend ActionView::Helpers::TranslationHelper
  prefix 'api'
  version 'v1', using: :path
  format :json

  helpers Margatsni::V1::Users::Auth
  mount Margatsni::V1::Users::Users
  add_swagger_documentation api_version: 'v1', hide_documentation_path: true
end
