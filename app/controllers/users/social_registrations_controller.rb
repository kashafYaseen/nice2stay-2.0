class Users::SocialRegistrationsController < ApplicationController

  def new
    return redirect_to root_path, alert: 'Authentication faild.' unless session['devise.omniauth_data']
    @user = User.build_by_provider session['devise.omniauth_data']
  end

  def create
    password = Devise.friendly_token[0,20]
    @user = User.new(user_params.merge(password: password, password_confirmation: password, creation_status: :with_social_site))
    if @user.save
      session.delete('devise.omniauth_data')
      redirect_to root_path, notice: I18n.t('devise.confirmations.send_instructions')
    else
      render :new
    end
  end

  def update
    @user = User.find_by(email: params[:user][:email])
    return redirect_to new_users_social_registration_path, alert: 'No associated account found with this email.' unless @user.present?
    social_logins_params = update_params[:social_logins_attributes]['0']

    @social_login = @user.social_logins.find_or_initialize_by(provider: social_logins_params[:provider], uid: social_logins_params[:uid], confirmed_at: nil) do |social_login|
      social_login.confirmation_token = Devise.friendly_token
      social_login.confirmation_sent_at = DateTime.current
      social_login.email = social_logins_params[:email]
    end

    if @social_login.save
      UserMailer.send_instructions(@user.id, @social_login.confirmation_token).deliver_now
      redirect_to root_path, notice: I18n.t('devise.confirmations.send_instructions')
    else
      redirect_to new_users_social_registration_path, alert: 'Unable to process your request at moment.'
    end
  end

  def confirmation
    @user = User.find(params[:id])
    @social_login = @user.social_logins.find_by(confirmation_token: params[:confirmation_token])
    if @social_login.present?
      @social_login.update(confirmed_at: DateTime.current, confirmation_token: nil)
      sign_in(@user)
      redirect_to dashboard_path, notice: I18n.t('devise.omniauth_callbacks.success', kind: @social_login.provider)
    else
      redirect_to root_path, alert: "Invalid authentication token"
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :creation_status, social_logins_attributes: [:provider, :uid, :email])
    end

    def update_params
      params.require(:user).permit(social_logins_attributes: [:provider, :uid, :email])
    end
end
