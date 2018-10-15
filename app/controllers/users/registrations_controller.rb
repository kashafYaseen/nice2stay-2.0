class Users::RegistrationsController < Devise::RegistrationsController
  protected
    def sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :city, :address, :country, :zipcode, :phone, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :image, :email, :city, :address, :country, :zipcode, :phone, :password, :password_confirmation, :current_password)
    end

    def after_update_path_for(resource)
      dashboard_path
    end
end
