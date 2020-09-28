class API::V1::RoomRaccoon::CreatePricesResponse
  attr_reader :xml_doc
  attr_reader :request_body

  def initialize(request_body)
    @request_body = request_body
    @xml_doc = Ox::Document.new
  end

  def success
    envelope = response_envelope
    body = response_body
    header = response_header
    header << Ox::Element.new('Success')
    body << header
    envelope << body
    xml_doc << envelope
    Ox.dump(xml_doc)
  end

  def errors
    envelope = response_envelope
    body = response_body
    header = response_header
    errors = Ox::Element.new('Errors')
    error = Ox::Element.new('Error')
    error['Type'] = 6
    error['Code'] = 392
    error << "Something went wrong!"
    errors << error
    header << errors
    body << header
    envelope << body
    xml_doc << envelope
    Ox.dump(xml_doc)
  end

  private
    def response_header
      header = Ox::Element.new('OTA_HotelRateAmountNotifRS')
      header['Version'] = request_body['OTA_HotelRateAmountNotifRQ']['Version']
      header['xmlns'] = request_body['OTA_HotelRateAmountNotifRQ']['xmlns']
      header['TimeStamp'] = DateTime.current
      header['EchoToken'] = request_body['OTA_HotelRateAmountNotifRQ']['EchoToken']
      header
    end

    def response_envelope
      envelope = Ox::Element.new('SOAP-ENV:Envelope')
      envelope['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
      envelope
    end

    def response_body
      body = Ox::Element.new('SOAP-ENV:Body')
      body['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
      body
    end
end
