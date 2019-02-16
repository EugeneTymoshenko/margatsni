module Margatsni
  module V1
    module Users
      class Users < Margatsni::V1::BaseV1
        helpers do
          def represent_user_with_token(user)
            present user, with: Margatsni::V1::Entities::User
          end
        end

        namespace :users do
          desc 'register a user'
          params do
            requires :username, type: String
            requires :email, type: String, regexp: /\A[^@\s]+@[^@\s]+\z/
            requires :password, type: String
          end
          post :registration do
            user = User.new(declared(params))
            user.save!
            represent_user_with_token(user)
          end

          desc 'user login'
          params do
            requires :email
            requires :password
          end
          post :login do
            user = User.find_by(email: params[:email])
            if user = User.authenticate(params[:email], params[:password])
              represent_user_with_token(user)
            else
              error!('Invalid email/password combination', 401)
            end
          end
        end
      end
    end
  end
end
