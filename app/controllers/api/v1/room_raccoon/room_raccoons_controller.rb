class Api::V1::RoomRaccoon::RoomRaccoonsController < ActionController::API
  def create
    @body = Hash.from_xml request.body.read
    @body = @body.deep_transform_keys(&:downcase)
    @body = @body['envelope']['body']

    if @body['ota_hotelavailrq'].present?
      hotel_id = @body['ota_hotelavailrq']['availrequestsegments']['availrequestsegment']['hotelsearchcriteria']['criterion']['hotelref']['hotelcode']
      response, response_flag = API::V1::RoomRaccoon::RetrieveRooms.call(hotel_id, @body)
      render xml: response, status: response_flag ? :ok : :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
    elsif @body['ota_hotelavailnotifrq'].present?
      hotel_id = @body['ota_hotelavailnotifrq']['availstatusmessages']['hotelcode']
      response = RoomRaccoons::CreateAvailabilities.call(@body['ota_hotelavailnotifrq'], hotel_id)

      if response
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreateAvailabilitiesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    elsif @body['ota_hotelrateamountnotifrq'].present?
      hotel_id = @body['ota_hotelrateamountnotifrq']['rateamountmessages']['hotelcode']
      response = RoomRaccoons::CreatePrices.call(@body['ota_hotelrateamountnotifrq'], hotel_id)

      if response
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).success, status: :ok, content_type: 'text/xml; charset=UTF-8'
      else
        render xml: API::V1::RoomRaccoon::CreatePricesResponse.new(@body).errors, status: :unprocessable_entity, content_type: 'text/xml; charset=UTF-8'
      end
    end
  end
end
