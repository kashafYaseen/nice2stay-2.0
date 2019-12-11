class Api::V2::OmniauthsController < Api::V2::ApiController
  def create
    user = User.from_omniauth(params)
    if user.present? && user.persisted?
      user.regenerate_auth_token
      render json: Api::V2::UserSerializer.new(user, { params: { auth_token: true } }).serialized_json, status: :created
    elsif user.present? && !user.persisted?
      unprocessable_entity(user.errors)
    else
      render json: Api::V2::UserSerializer.new(user).serialized_json, status: :created
    end
  end

  def update
    if params[:sign_up] || params[:sign_up] == 'true'
      return render json: { email: user_params[:email], already_registered: true }, status: :ok if User.find_by(email: user_params[:email]).present?

      password = Devise.friendly_token[0, 20]
      user = User.new(user_params.merge(password: password, password_confirmation: password, creation_status: :with_social_site))
      if user.save
        render json: Api::V2::UserSerializer.new(user, { params: { auth_token: true } }).serialized_json, status: :created
      else
        unprocessable_entity(user.errors)
      end
    else
      user = User.find_by(email: params[:user][:email])
      return unprocessable_entity('No associated account found with this email.') unless user.present?
      social_logins_params = update_params[:social_logins_attributes]['0']

      @social_login = user.social_logins.find_or_initialize_by(provider: social_logins_params[:provider], uid: social_logins_params[:uid], confirmed_at: nil) do |social_login|
        social_login.confirmation_token = Devise.friendly_token
        social_login.confirmation_sent_at = DateTime.current
        social_login.email = social_logins_params[:email]
      end

      if @social_login.save
        UserMailer.send_instructions(user.id, @social_login.confirmation_token).deliver_now
        return render json: { success: I18n.t('devise.confirmations.send_instructions') }, status: :created
      else
        return unprocessable_entity('Unable to process your request at moment.')
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, social_logins_attributes: [:provider, :uid, :email, :confirmed_at])
    end

    def update_params
      params.require(:user).permit(social_logins_attributes: [:provider, :uid, :email])
    end
end
