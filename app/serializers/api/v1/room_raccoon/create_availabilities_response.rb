class API::V1::RoomRaccoon::CreateAvailabilitiesResponse
  attr_reader :xml_doc
  attr_reader :request_body

  def initialize(request_body)
    @request_body = request_body
    @xml_doc = Ox::Document.new
  end

  def response_header
    header = Ox::Element.new('OTA_HotelAvailNotifRS')
    header['Version'] = request_body['OTA_HotelAvailNotifRQ']['Version']
    header['xmlns'] = request_body['OTA_HotelAvailNotifRQ']['xmlns']
    header['TimeStamp'] = DateTime.current
    header['EchoToken'] = request_body['OTA_HotelAvailNotifRQ']['EchoToken']
    header
  end

  def success
    header = response_header
    header << Ox::Element.new('Success')
    xml_doc << header
    Ox.dump(xml_doc)
  end

  def errors
    header = response_header
    errors = Ox::Element.new('Errors')
    error = Ox::Element.new('Error')
    error['Type'] = 6
    error['Code'] = 392
    error << "Something went wrong!"
    errors << error
    header << errors
    xml_doc << header
    Ox.dump(xml_doc)
  end
end
