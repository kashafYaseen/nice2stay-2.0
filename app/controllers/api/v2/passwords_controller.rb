class Api::V2::PasswordsController < Api::V2::ApiController

  def create
    user = User.find_by(email: forgot_email_params[:email])
    if user
      user.generate_reset_token
      render json: I18n.t('forgot_password.mail_sent'), status: :ok
    else
      render json: I18n.t('forgot_password.email_not_found'), status: :ok
    end
  end

  def update
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, password_update_params[:reset_password_token])
    user = User.find_by(reset_password_token: reset_password_token)
    if user
      if user.update(password_update_params)
        user.update_columns(reset_password_token: nil, reset_password_sent_at: nil)
        render json: I18n.t('forgot_password.update'), status: :ok
      else
        render json: I18n.t('forgot_password.error_message'), status: :ok
      end
    else
      render json: I18n.t('forgot_password.invalid_token'), status: :ok
    end
  end

  private
    def forgot_email_params
      params.require(:user).permit(:email)
    end

    def password_update_params
      params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
    end
end
