class Api::V2::SocialsController < Api::V2::ApiController
  def create
    if social_params[:provider] == SocialLogin::PROVIDERS[:google]
      user = Google::People.new(social_params[:authorization_code]).config_user
    end

    render json: Api::V2::UserSerializer.new(user, { params: { auth_token: true } }).serialized_json, status: :created
  end

  private
    def social_params
      params.require(:social).permit(:authorization_code, :provider)
    end
end
