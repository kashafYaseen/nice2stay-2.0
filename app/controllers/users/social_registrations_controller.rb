class Users::SocialRegistrationsController < ApplicationController

  def new
    return redirect_to root_path, alert: 'Authentication faild.' unless session['devise.omniauth_data']
    @user = User.build_by_provider session['devise.omniauth_data']
  end

  def create
    password = Devise.friendly_token[0,20]
    @user = User.new(user_params.merge(password: password, password_confirmation: password))
    if @user.save
      session.delete('devise.omniauth_data')
      redirect_to root_path, notice: I18n.t('devise.confirmations.send_instructions')
    else
      render :new
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, social_logins_attributes: [:provider, :uid, :email])
    end
end
