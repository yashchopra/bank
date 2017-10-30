class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(email, code)
    @code = code
    @email = email
    mail(to: @email, subject: 'Your OTP')
  end

  def send_trans_otp(email, code)
    @code = code
    @email = email
    mail(to: @email, subject: 'Your Transaction OTP')
  end
end
