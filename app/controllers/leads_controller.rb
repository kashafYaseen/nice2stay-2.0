class LeadsController < ApplicationController
  before_action :set_user

  def create
    @lead = @user.leads.build(lead_params)
    return redirect_to root_path, notice: "Lead was created successfully." if @lead.save && @user.valid?
  end

  private
    def set_user
      return @user = current_user if current_user.present?

      if params[:create_account].present?
        @user = User.with_login.new(user_params)
      else
        @user = User.without_login.find_or_initialize_by(email: user_params[:email])
        @user.attributes = user_params
        @user.password = @user.password_confirmation = Devise.friendly_token[0, 20]
      end
    end

    def user_params
      params[:lead].require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def lead_params
      params.require(:lead).permit(:from, :to, :adults, :childrens, :extra_information, { country_ids: [] })
    end
end
