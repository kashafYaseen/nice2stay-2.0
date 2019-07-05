class UserMailer < ApplicationMailer
  def send_instructions(user_id, token)
    @user = User.find_by_id(user_id)
    @social_login = @user.social_logins.find_by(confirmation_token: token)
    mail(to: @user.email, subject: "Reuqest to Connect Social Account")
  end
end
