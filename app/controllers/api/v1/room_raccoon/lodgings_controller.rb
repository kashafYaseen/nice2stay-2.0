class Api::V1::RoomRaccoon::LodgingsController < Api::V1::RoomRaccoon::ApiController
  def create
    @body = Hash.from_xml request.body.read
    @body = @body['Envelope']['Body']
    hotel_id = @body['OTA_HotelAvailRQ']['AvailRequestSegments']['AvailRequestSegment']['HotelSearchCriteria']['Criterion']['HotelRef']['HotelCode']
    @rooms = Lodging.find_by(id: hotel_id)&.lodging_children
    render xml: API::V1::RoomRaccoon::RetrieveRooms.call(@rooms, @body), status: @rooms.present? ? :ok : :unprocessable_entity
  end
end
