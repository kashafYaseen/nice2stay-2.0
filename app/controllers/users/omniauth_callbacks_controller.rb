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

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: omniauth_provider
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.omniauth_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end

    def omniauth_provider
      provider = request.env['omniauth.auth'].provider
      return 'Google' if provider == 'google_oauth2'
      provider
    end
end
