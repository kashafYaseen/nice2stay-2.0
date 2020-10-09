class Api::V1::RoomRaccoon::RoomRaccoonsController < ActionController::API
  def create
    @body = Hash.from_xml request.body.read
    @body = @body['Envelope']['Body']

    if @body['OTA_HotelAvailRQ'].present?
      hotel_id = @body['OTA_HotelAvailRQ']['AvailRequestSegments']['AvailRequestSegment']['HotelSearchCriteria']['Criterion']['HotelRef']['HotelCode']
      @rooms = Lodging.find_by(id: hotel_id)&.lodging_children
      render xml: API::V1::RoomRaccoon::RetrieveRooms.call(@rooms, @body), status: @rooms.present? ? :ok : :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
    elsif @body['OTA_HotelAvailNotifRQ'].present?
      hotel_id = @body['OTA_HotelAvailNotifRQ']['AvailStatusMessages']['HotelCode']
      hotel = Lodging.find_by(id: hotel_id)
      response = RoomRaccoons::CreateAvailabilities.call(@body, hotel)

      if response
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    elsif @body['OTA_HotelRateAmountNotifRQ'].present?
      hotel_id = @body['OTA_HotelRateAmountNotifRQ']['RateAmountMessages']['HotelCode']
      hotel = Lodging.find_by(id: hotel_id)
      response = RoomRaccoons::CreatePrices.call(@body, hotel)

      if response
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    end
  end
end
