class Api::V2::ProfilesController < Api::V2::ApiController
  def create
    @user = User.new(user_sign_up_params)
    if @user.save
      render json: Api::V2::UserSerializer.new(@user, { params: { auth_token: true } }).serialized_json, status: :ok
    else
      unprocessable_entity(@user.errors)
    end
  end

  private
    def user_sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end
