class Api::V2::UsersController < Api::V2::ApiController
  before_action :authenticate, only: [:update, :destroy, :show]
  before_action :set_user, only: [:show, :destroy, :update]

  def create
    @user = User.new(user_params)
    if @user.save
      render status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @user.update(user_params)
      render status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def set_user
      @user = User.find(params[:id])
    end
end
