class API::V1::RoomRaccoon::RetrieveRooms
  attr_accessor :rooms, :xml_doc, :request_body, :response_body

  def initialize(hotel_id:, body:)
    @rooms = Lodging.find(hotel_id).lodging_children.joins(:room_rate_plans)&.select('lodgings.id as room_id, lodgings.name as room_name, lodgings.short_desc as room_description, rate_plans.id as rate_id, rate_plans.name as rate_name, rate_plans.description as rate_description')
    @request_body = body
    @xml_doc = Ox::Document.new
  end

  def self.call(hotel_id:, body:)
    new(hotel_id: hotel_id, body: body).call
  end

  def call
    response_envelope = Ox::Element.new('SOAP-ENV:Envelope')
    response_envelope['xmlns:SOAP-ENV'] = 'http://schemas.xmlsoap.org/soap/envelope/'
    response_body = Ox::Element.new('SOAP-ENV:Body')
    response_body['xmlns:SOAP-ENV'] = 'http://schemas.xmlsoap.org/soap/envelope/'
    header = room_retrieval_header

    if rooms.present?
      header << Ox::Element.new('Success')
      room_stays = list_rooms
      header << room_stays
    else
      header << errors
    end

    response_body << header
    response_envelope << response_body
    xml_doc << response_envelope
    [Ox.dump(xml_doc), rooms.present? ? true : false]
  end

  def room_retrieval_header
    header = Ox::Element.new('OTA_HotelAvailRS')
    header['Version'] = request_body['ota_hotelavailrq']['version']
    header['xmlns'] = request_body['ota_hotelavailrq']['xmlns']
    header['TimeStamp'] = DateTime.current
    header['EchoToken'] = request_body['ota_hotelavailrq']['echotoken']
    header
  end

  def list_rooms
    room_stays = Ox::Element.new('RoomStays')

    rooms.each do |room|
      room_stay = Ox::Element.new('RoomStay')
      room_types = Ox::Element.new('RoomTypes')
      room_type = Ox::Element.new('RoomType')
      room_type['RoomTypeCode'] = room.room_id
      room_description = Ox::Element.new('RoomDescription')
      room_description['Name'] = room.room_name
      if room.room_description.present?
        room_description_text = Ox::Element.new('Text')
        room_description_text << room.room_description
        room_description << room_description_text
      end

      room_type << room_description
      room_types << room_type
      room_stay << room_types
      rate_plans = Ox::Element.new('RatePlans')
      rate_plan = Ox::Element.new('RatePlan')
      rate_plan['RatePlanCode'] = room.rate_id
      rate_plan_description = Ox::Element.new('RatePlanDescription')
      rate_plan_description['Name'] = room.rate_name
      if room.rate_description.present?
        rate_plan_description_text = Ox::Element.new('Text')
        rate_plan_description_text << room.rate_description
        rate_plan_description << rate_plan_description_text
      end

      rate_plan << rate_plan_description
      rate_plans << rate_plan
      room_stay << rate_plans
      room_stays << room_stay
    end

    room_stays
  end

  def errors
    errors = Ox::Element.new('Errors')
    error = Ox::Element.new('Error')
    error['Type'] = 6
    error['Code'] = 392
    error << 'Rooms Not Found!'
    errors << error
    errors
  end
end
