class Api::V1::ApiController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found_error
  before_action :filter_ip

  protected
    def not_acceptable(errors)
      render json: { errors: errors }, status: :not_acceptable
      return
    end

    def unprocessable_entity(errors)
      render json: { errors: errors }, status: :unprocessable_entity
      return
    end

    def not_authenticated
      render json: { errors: ['IP not authorized'] }, status: :unauthorized
      return
    end

    def filter_ip
      return unless Rails.env.production?
      logger.debug "*" * 100000
      logger.debug "IP: #{request.remote_ip}"
      logger.debug ENV['CRM_REMOTE_IP'] == request.remote_ip
      logger.debug "IP: #{ENV['CRM_REMOTE_IP']}"
      not_authenticated unless ENV['CRM_REMOTE_IP'] == request.remote_ip
    end
end
