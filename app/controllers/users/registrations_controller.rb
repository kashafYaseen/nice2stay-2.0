class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_title, only: [:edit, :update]
  layout 'dashboard', only: [:edit, :update, :edit_password, :update_password]

  def edit_password
    self.resource = current_user
  end

  def update_password
    self.resource = current_user
    if current_user.update_with_password(account_update_params)
      bypass_sign_in resource, scope: resource_name
      redirect_to dashboard_path, notice: I18n.t('devise.passwords.updated_not_active')
    else
      clean_up_passwords resource
      set_minimum_password_length
      render :edit_password
    end
  end

  protected
    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :city, :address, :country_id, :zipcode, :phone, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :image, :email, :city, :address, :country_id, :zipcode, :phone, :password, :password_confirmation, :current_password, :language)
    end

    def after_update_path_for(resource)
      dashboard_path
    end

    def update_resource(resource, params)
      resource.update_without_password(params)
    end

  private
    def set_title
      @title = 'Profile'
      add_breadcrumb 'Dashboard', :dashboard_path
      add_breadcrumb @title
    end
end
