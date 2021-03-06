# frozen_string_literal: true

Rails.application.routes.draw do
  mount Margatsni::ApiBase => '/'
  mount GrapeSwaggerRails::Engine => '/swagger_doc'
end
