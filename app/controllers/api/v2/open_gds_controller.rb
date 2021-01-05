class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    property_ids = []
    accommodation_ids = []
    params[:_json].each do |rate|
      property_ids << rate[:property_id]
      accommodation_ids << rate[:accommodations].map { |accom| accom[:accom_id] }
    end

    lodgings = Lodging.where(open_gds_property_id: property_ids).joins(:room_types).where(room_types: { open_gds_accommodation_id: accommodation_ids.flatten })
    OpenGdsCreateRatesJob.perform_later params[:_json].map(&:to_unsafe_h) if lodgings.present?
    render json: { response: lodgings.present? }, status: lodgings.present? ? :ok : :unprocessable_entity
  end
end
