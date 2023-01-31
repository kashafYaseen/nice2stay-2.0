class ForgotPasswordService
  attr_reader :user

  def self.call(user)
    self.new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
    user.update(reset_password_token: enc_token, reset_password_sent_at: Time.now.utc)
    UserMailer.forgot_password_email(user, token).deliver_now
  end
end
