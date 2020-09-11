class API::V1::RoomRaccoon::LodgingSerializer
  attr_accessor :lodgings
  attr_accessor :xml_doc
  attr_accessor :request_body

  def initialize(lodgings, body)
    @lodgings = lodgings
    @request_body = body
    @xml_doc = Ox::Document.new
  end

  def room_retrieval_header
    header = Ox::Element.new('OTA_HotelAvailRS')
    header['Version'] = '1.0'
    header['xmlns'] = request_body['OTA_HotelAvailRQ']['xmlns']
    header['TimeStamp'] = DateTime.current
    header['EchoToken'] = request_body['OTA_HotelAvailRQ']['EchoToken']
    header
  end

  def retrieve_rooms
    header = room_retrieval_header
    header << Ox::Element.new('Success')
    room_stays = Ox::Element.new('RoomStays')
    lodgings.each do |lodging|
      room_stay = Ox::Element.new('RoomStay')
      room_types = Ox::Element.new('RoomTypes')
      room_type = Ox::Element.new('RoomType')
      room_type['RoomTypeCode'] = lodging.rr_room_type_code
      room_description = Ox::Element.new('RoomDescription')
      room_description['Name'] = lodging.rr_room_type_description
      room_type << room_description
      room_types << room_type
      room_stay << room_types
      room_stays << room_stay
    end
    header << room_stays
    xml_doc << header
    Ox.dump(xml_doc)
  end

  def errors
    header = room_retrieval_header
    errors = Ox::Element.new('Errors')
    error = Ox::Element.new('Error')
    error['Type'] = 6
    error['Code'] = 392
    error << "Rooms Not Found!"
    errors << error
    header << errors
    xml_doc << header
    Ox.dump(xml_doc)
  end
end
