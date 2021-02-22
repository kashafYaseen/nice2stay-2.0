class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_interface_id] }
    end

    room_types = RoomType.where(id: accommodation_ids.flatten)
    if room_types.present?
      OpenGdsCreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h)
      render json: { response: 'Success' }, status: :ok
    else
      render json: { response: 'Property/Accommodations Not Found!' }, status: :unprocessable_entity
    end
  end
end
