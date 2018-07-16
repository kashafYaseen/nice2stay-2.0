class Api::V2::ApiController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error

  def current_user
    @current_user
  end

  def set_current_user(user)
    @current_user = user
  end

  protected
    def authenticate
      authenticate_token || not_authenticated
    end

    def not_acceptable(errors)
      render json: { errors: errors }, status: :not_acceptable
      return
    end

    def unprocessable_entity(errors)
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end

    def not_authenticated
      render json: { errors: ['User not authorized'] }, status: :unauthorized
      return
    end

    def authenticate_token
      return false unless user_id_in_token?

      @current_user = User.find_by(id: auth_token[:user_id])
      return false unless @current_user.present?
      set_current_user @current_user
      true
    end

  private
    def record_not_found_error
      render json: { errors: ['Object was not found'] }, status: :not_found
    end

    def http_token
      @http_token = request.headers['AUTH-TOKEN']
    end

    def auth_token
      @auth_token = JsonWebToken.decode(http_token)
    end

    def user_id_in_token?
      http_token && auth_token && !auth_token.is_a?(String) && auth_token[:user_id].to_i
    end
end
