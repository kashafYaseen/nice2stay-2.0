class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_title, only: [:edit, :update]
  layout 'dashboard', only: [:edit, :update]

  protected
    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :city, :address, :country_id, :zipcode, :phone, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :image, :email, :city, :address, :country_id, :zipcode, :phone, :password, :password_confirmation, :current_password)
    end

    def after_update_path_for(resource)
      dashboard_path
    end

    def update_resource(resource, params)
      if resource.with_social_site?
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end

  private
    def set_title
      @title = 'Profile'
      add_breadcrumb 'Dashboard', :dashboard_path
      add_breadcrumb @title
    end
end
