class Api::V1::RoomRaccoon::AvailabilitiesController < Api::V1::RoomRaccoon::ApiController
  def create
    @body = Hash.from_xml request.body.read
    @body = @body['Envelope']['Body']
    hotel_id = @body['OTA_HotelAvailNotifRQ']['AvailStatusMessages']['HotelCode']
    hotel = Lodging.find_by(id: hotel_id)
    response = RoomRaccoons::CreateAvailabilities.call(@body, hotel)

    if response
      render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).success, status: :ok
    else
      render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).errors, status: :unprocessable_entity
    end
  end
end
