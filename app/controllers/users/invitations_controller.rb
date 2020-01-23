class Users::InvitationsController < Devise::InvitationsController
  protected
    def update_resource_params
      params.require(:user).permit(:first_name, :last_name, :email, :skip_validations, :password, :password_confirmation, :invitation_token)
    end
end
