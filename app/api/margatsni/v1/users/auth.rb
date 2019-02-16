module Margatsni::V1::Users::Auth
  def validate_token!
    TokenProvider.valid?(token)
  rescue
    error!('Unauthorized', 401)
  end

  def authenticate!
    payload, header = TokenProvider.valid?(token)
    @current_user = User.find_by(id: payload['user_id'])
  rescue
    error!('Unauthorized', 401)
  end

  def current_user
    @current_user ||= authenticate!
  end

  def token
    request.headers['Authorization'].split(' ').last
  end
end
