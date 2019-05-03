class UserMailer < ApplicationMailer
  def registration_confirmation
    @user = params[:user]
    @url  = URI::HTTP.build(
      host: ENV['URL_HOST'],
      port: '3000',
      path: '/api/v1/users/confirm_email',
      query: { token: @user.confirm_token }.to_query
    )
    mail(to: @user.email, subject: 'Welcome to Margatsni! Please confirm your registration!')
  end
end
