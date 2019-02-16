module Margatsni
  class ApiBase < Grape::API
    default_format :json
    # helpers Pundit
    mount Margatsni::V1::BaseV1
  end
end
