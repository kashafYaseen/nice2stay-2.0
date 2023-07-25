class Crm::V1::AdminUser::SessionsController < Crm::V1::ApiController
  before_action :authenticate, only: [:update]

  def create
    @user = User.authenticate(email: params[:email], password: params[:password])
    return invalid_credentials unless @user.present?
    @user.regenerate_auth_token
    render json: Crm::V1::UserSerializer.new(@user, { params: { auth_token: true } }).serialized_json, status: :created
  end

end
