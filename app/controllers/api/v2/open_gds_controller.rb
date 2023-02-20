class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_interface_id] }
    end

    lodgings = Lodging.where(id: accommodation_ids.flatten)
    if lodgings.present?
      OpenGds::CreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h)
      Rails.logger.info "================================================================="
      Rails.logger.info " Rate Data========================>>#{ params[:_json].map(&:to_unsafe_h)}"
      Rails.logger.info "================================================================="
      render json: { response: 'Success' }, status: :ok
    elsif ['https://www.staging.nice2stay.net', 'https://backend.nice2stay.com'].include? ENV['BASE_URL']
      render json: { response: 'Property/Accommodations Not Found on Server!' }, status: :ok
    else
      render json: { response: 'Property/Accommodations Not Found!' }, status: :unprocessable_entity
    end
  end
end
