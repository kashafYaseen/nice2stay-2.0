class Users::PasswordsController < Devise::PasswordsController
  respond_to :html, :js

  def create
    respond_to do |format|
      format.html { super }
      format.js do
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        yield resource if block_given?

        if successfully_sent?(resource)
          flash.now[:notice] = t('devise.passwords.send_instructions')
        end
      end
    end
  end
end
