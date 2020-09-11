class Api::V1::RoomRaccoon::LodgingsController < Api::V1::RoomRaccoon::ApiController
  def index
    @body = Hash.from_xml request.body.read
    hotel_id = @body['OTA_HotelAvailRQ']['AvailRequestSegments']['AvailRequestSegment']['HotelSearchCriteria']['Criterion']['HotelRef']['HotelCode']
    @lodgings = Lodging.find_by(id: hotel_id)&.lodging_children
    if @lodgings.present?
      @response = API::V1::RoomRaccoon::LodgingSerializer.new(@lodgings, @body).retrieve_rooms
      render xml: @response, status: :ok
    else
      @response = API::V1::RoomRaccoon::LodgingSerializer.new(@lodgings, @body).errors
      render xml: @response, status: :unprocessable_entity
    end
  end
end
