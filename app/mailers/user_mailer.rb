class UserMailer < ApplicationMailer
  layout false, only: :forgot_password_email

  def send_instructions(user_id, token)
    @user = User.find_by_id(user_id)
    @social_login = @user.social_logins.find_by(confirmation_token: token)
    mail(to: @user.email, subject: "Reuqest to Connect Social Account")
  end

  def forgot_password_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: I18n.t('forgot_password.subject'))
  end
end
