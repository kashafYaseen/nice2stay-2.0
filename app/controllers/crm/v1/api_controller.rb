class Crm::V1::ApiController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error

  protected

    def record_not_found_error
      render json: { errors: ['Object was not found'] }, status: :not_found
    end

    def unprocessable_entity(errors)
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end

end
