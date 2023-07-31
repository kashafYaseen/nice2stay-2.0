class Crm::V1::AdminUser::SessionsController < Crm::V1::AdminUser::ApiController

  def create
    @user = AdminUser.authenticate(email: params[:email], password: params[:password])
    return invalid_credentials unless @user.present?

    @user.regenerate_auth_token
    render json: Crm::V1::AdminUserSerializer.new(@user, { params: { auth_token: true } }).serialized_json, status: :created
  end

end
