class MailSenderWorker
  include Sidekiq::Worker

  def perform(username, email)
    UserMailer.registration_confirmation(username, email).deliver
  end
end
