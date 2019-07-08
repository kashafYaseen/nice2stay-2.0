class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  SocialLogin::SOCIAL_SITES.each do |name|
    define_method name do
      social_site
    end
  end

  def failure
    redirect_to root_path
  end

  private
    def social_site
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.present? && @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: omniauth_provider
        session[:social_site] = omniauth_provider
        sign_in_and_redirect @user, event: :authentication
      elsif @user.present? && !@user.persisted?
        session['devise.omniauth_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to root_path, alert: @user.errors.full_messages.join("\n")
      else
        session['devise.omniauth_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_users_social_registration_path
      end
    end

    def omniauth_provider
      provider = request.env['omniauth.auth'].provider
      return 'Google' if provider == 'google_oauth2'
      provider
    end
end
