class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      property_ids << rate[:property_id]
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_id] }
    end

    room_types = RoomType.joins(:parent_lodging).where(lodgings: { open_gds_property_id: property_ids }, room_types: { open_gds_accommodation_id: accommodation_ids.flatten })
    OpenGdsCreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h) if room_types.present?
    render json: { response: room_types.present? }, status: room_types.present? ? :ok : :unprocessable_entity
  end
end
