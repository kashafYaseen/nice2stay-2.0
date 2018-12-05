class Users::SessionsController < Devise::SessionsController
  respond_to :html, :js

  private
    def after_sign_in_path_for(resource)
      dashboard_path
    end
end
