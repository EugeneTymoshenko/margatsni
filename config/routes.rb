# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Margatsni::ApiBase => '/'
  mount GrapeSwaggerRails::Engine => '/swagger_doc'
  mount Sidekiq::Web => '/sidekiq'
end
