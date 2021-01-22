class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_interface_id] }
    end

    room_types = RoomType.where(id: accommodation_ids.flatten)
    OpenGdsCreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h) if room_types.present?
    render json: { response: room_types.present? }, status: room_types.present? ? :ok : :unprocessable_entity
  end
end
