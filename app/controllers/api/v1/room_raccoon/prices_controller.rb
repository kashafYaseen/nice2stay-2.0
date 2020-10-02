class Api::V1::RoomRaccoon::PricesController < Api::V1::RoomRaccoon::ApiController
  def create
    @body = Hash.from_xml request.body.read
    @body = @body['Envelope']['Body']
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
