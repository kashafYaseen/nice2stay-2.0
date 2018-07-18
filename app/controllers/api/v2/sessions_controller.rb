class Api::V2::SessionsController < Api::V2::ApiController
  before_action :authenticate, only: [:update]

  def create
    @user = User.authenticate(email: params[:email], password: params[:password])
    return not_authenticated unless @user.present?
    @user.regenerate_auth_token
    render status: :created
  end

  def update
    current_user.regenerate_auth_token
    render status: :created
  end
end
