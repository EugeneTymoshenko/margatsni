# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq/web'

sidekiq_config = { url: ENV['JOB_WORKER_URL'] }

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['SIDEKIQ_USER'], ENV['SIDEKIQ_PASSWORD']]
end

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
