class Api::V2::SocialsController < Api::V2::ApiController
  def create
    if social_params[:provider] == SocialLogin::PROVIDERS[:google]
      access_token = Google::Authorization.new(social_params).access_token
      puts "access_token ---------------#{access_token}"
      render json: {access_token: access_token}, status: :created
    end
  end

  def user_info
    if user_info_params[:provider] == SocialLogin::PROVIDERS[:google]
      first_name = user_info_params[:family_name]
      last_name = user_info_params[:given_name]
    elsif user_info_params[:provider] == SocialLogin::PROVIDERS[:facebook]
      name = user_info_params[:family_name].to_s.split(" ")
      first_name = name.first
      last_name = name[1..name.size].join(' ')
    end

    user =  User.configure_social_login_user(
      uid: user_info_params[:sub],
      email: user_info_params[:email],
      provider: user_info_params[:provider],
      first_name: first_name,
      last_name: last_name
    )
    puts "User Found ---------------#{user&.id}"
    render json: Api::V2::UserSerializer.new(user, { params: { auth_token: true } }).serialized_json, status: :created
  end

  private
    def social_params
      params.permit(:code, :provider, :redirect_uri)
    end

    def user_info_params
      params.permit(:email, :sub, :given_name, :family_name, :provider)
    end
end
