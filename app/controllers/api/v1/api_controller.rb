class Api::V1::ApiController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error

  protected
    def not_acceptable(errors)
      render json: { errors: errors }, status: :not_acceptable
      return
    end

    def unprocessable_entity(errors)
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end
end
