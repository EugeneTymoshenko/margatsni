class UserMailer < ApplicationMailer
  def registration_confirmation(username, email)
    @username = username
    # @url      = URI::HTTP.build(
    #   host: ENV['URL_HOST'],
    #   port: '3000',
    #   path: '/api/v1/users/confirm_email',
    #   query: { token: token }.to_query
    # )
    mail(to: email, subject: 'Welcome to Margatsni! Please confirm your registration!')
  end
end
