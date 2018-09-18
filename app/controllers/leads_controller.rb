class LeadsController < ApplicationController
  def create
    create_user unless current_user.present?
    @lead = @user.leads.build(lead_params)
    return redirect_to root_en_path, notice: "Lead was created successfully." if @lead.save && @user.valid?
  end

  private
    def create_user
      if params[:create_account].present?
        @user = User.with_login.new(user_params)
      else
        @user = User.without_login.find_or_initialize_by(email: user_params[:email])
        @user.attributes = user_params
        @user.password = @user.password_confirmation = Devise.friendly_token[0, 20]
      end
      return true if @user.save
    end

    def user_params
      params[:lead].require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def lead_params
      params.require(:lead).permit(:from, :to, :adults, :childrens, :extra_information)
    end
end
