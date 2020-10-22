class Api::V1::RoomRaccoon::RoomRaccoonsController < ActionController::API
  def create
    @body = Hash.from_xml request.body.read
    @body = @body.deep_transform_keys(&:downcase)
    @body = @body['envelope']['body']

    if @body['ota_hotelavailrq'].present?
      hotel_id = @body['ota_hotelavailrq']['availrequestsegments']['availrequestsegment']['hotelsearchcriteria']['criterion']['hotelref']['hotelcode']
      @rooms = Lodging.find_by(id: hotel_id)&.lodging_children
      render xml: API::V1::RoomRaccoon::RetrieveRooms.call(@rooms, @body), status: @rooms.present? ? :ok : :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
    elsif @body['ota_hotelavailnotifrq'].present?
      hotel_id = @body['ota_hotelavailnotifrq']['availstatusmessages']['hotelcode']
      hotel = Lodging.find_by(id: hotel_id)
      response = RoomRaccoons::CreateAvailabilities.call(@body['ota_hotelavailnotifrq'], hotel)

      if response
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    elsif @body['ota_hotelrateamountnotifrq'].present?
      hotel_id = @body['ota_hotelrateamountnotifrq']['rateamountmessages']['hotelcode']
      hotel = Lodging.find_by(id: hotel_id)
      response = RoomRaccoons::CreatePrices.call(@body['ota_hotelrateamountnotifrq'], hotel)

      if response
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    end
  end
end
