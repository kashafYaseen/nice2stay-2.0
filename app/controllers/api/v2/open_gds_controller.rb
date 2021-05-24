class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_interface_id] }
    end

    lodgings = Lodging.where(id: accommodation_ids.flatten)
    if lodgings.present?
      OpenGdsCreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h)
      render json: { response: 'Success' }, status: :ok
    elsif ENV['BASE_URL'].include?(%w[https://www.staging.nice2stay.net http://localhost:3000])
      render json: { response: 'Property/Accommodations Not Found(Staging Server)!' }, status: :ok
    else
      render json: { response: 'Property/Accommodations Not Found!' }, status: :unprocessable_entity
    end
  end
end
