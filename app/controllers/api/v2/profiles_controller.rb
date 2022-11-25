class Api::V2::ProfilesController < Api::V2::ApiController
  before_action :authenticate, except: [:create]

  def show
    render json: Api::V2::UserSerializer.new(current_user).serialized_json, status: :ok
  end

  def create
    @user = User.new(user_sign_up_params)
    if @user.save
      render json: Api::V2::UserSerializer.new(@user, { params: { auth_token: true } }).serialized_json, status: :ok
    else
      unprocessable_entity(@user.errors)
    end
  end

  def update
    if current_user.update(account_update_params)
      render json: Api::V2::UserSerializer.new(current_user).serialized_json, status: :ok
    else
      unprocessable_entity(current_user.errors)
    end
  end

  def update_password
    if current_user.update_with_password(password_params)
      render json: Api::V2::UserSerializer.new(current_user).serialized_json, status: :ok
    else
      unprocessable_entity(current_user.errors)
    end
  end

  private
    def user_sign_up_params
      params.require(:user).permit(:first_name, :last_name, :email, :phone, :city, :address, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:first_name, :last_name, :image_url, :city, :address, :country_id, :zipcode, :phone, :language, :email)
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation, :current_password)
    end
end
