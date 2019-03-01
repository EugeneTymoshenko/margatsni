class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_reader :current_active_admin_user

  def authenticate_active_admin_user!
    false
  end
end
