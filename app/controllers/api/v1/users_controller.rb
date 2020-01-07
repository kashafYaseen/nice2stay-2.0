class Api::V1::UsersController < Api::V1::ApiController
  def create
    @user = User.find_or_initialize_by(email: user_params[:email])
    @user.attributes = user_params.merge(confirmed_at: DateTime.now)
    @user.country = Country.friendly.find(params[:user][:country_slug]) if params[:user][:country_slug].present?

    if @user.save(validate: false)
      render json: @user, status: :created
    else
      unprocessable_entity(@user.errors)
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :city,
        :zipcode,
        :phone,
        :address,
        :language,
      )
    end
end
