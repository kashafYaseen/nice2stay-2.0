class Api::V1::RoomRaccoon::LodgingsController < Api::V1::RoomRaccoon::ApiController
  def index
    @body = Hash.from_xml request.body.read
    hotel_id = @body['OTA_HotelAvailRQ']['AvailRequestSegments']['AvailRequestSegment']['HotelSearchCriteria']['Criterion']['HotelRef']['HotelCode']
    @rooms = Lodging.find_by(id: hotel_id)&.lodging_children
    if @rooms.present?
      render xml: API::V1::RoomRaccoon::RetrieveRooms.new(@rooms, @body).call, status: :ok
    else
      render xml: API::V1::RoomRaccoon::RetrieveRooms.new(@rooms, @body).errors, status: :unprocessable_entity
    end
  end
end
