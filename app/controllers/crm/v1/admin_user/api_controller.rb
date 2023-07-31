class Crm::V1::AdminUser::ApiController < ActionController::API
  include Pagy::Backend
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error


  def current_user
    @current_user
  end

  def set_current_user(user)
    @current_user = user
  end

  protected
    def set_user_if_present
      authenticate_token
    end

    def authenticate
      authenticate_token || not_authenticated
    end

    def record_not_found_error
      render json: { errors: ['Object was not found'] }, status: :not_found
    end

    def unprocessable_entity(errors)
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end

    def invalid_credentials
      render json: { errors: [I18n.t('devise.failure.invalid', authentication_keys: 'email')] }, status: :unauthorized
      return
    end


    def authenticate_token
      return false unless admin_user_id_in_token?

      @current_user = AdminUser.find_by(id: auth_token[:admin_user_id])
      return false unless @current_user.present?
      set_current_user @current_user
      true
    end

    def not_authenticated
      render json: { errors: ['User not authorized'] }, status: :unauthorized
      return
    end

    private
    def http_token
      @http_token = request.headers['AUTH-TOKEN']
    end

    def auth_token
      @auth_token = JsonWebToken.decode(http_token)
    end

    def admin_user_id_in_token?
      http_token && auth_token && !auth_token.is_a?(String) && auth_token[:admin_user_id].to_i
    end
end