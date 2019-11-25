class Api::V2::SessionsController < Api::V2::ApiController
  before_action :authenticate, only: [:update]

  def create
    @user = User.authenticate(email: params[:email], password: params[:password])
    return invalid_credentials unless @user.present?
    @user.regenerate_auth_token
    render json: Api::V2::UserSerializer.new(@user, { params: { auth_token: true } }).serialized_json, status: :created
  end

  def update
    current_user.regenerate_auth_token
    render json: Api::V2::UserSerializer.new(current_user, { params: { auth_token: true } }).serialized_json, status: :created
  end
end
