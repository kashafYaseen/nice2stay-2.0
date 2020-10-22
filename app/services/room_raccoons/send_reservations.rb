class RoomRaccoons::SendReservations
  attr_reader :hotel
  attr_reader :uri
  attr_reader :xml_doc

  def self.call(hotel)
    self.new(hotel).call
  end

  def initialize(hotel)
    @hotel = hotel
    @uri = URI.parse("https://api.roomraccoon.com/api")
    @xml_doc = Ox::Document.new
  end

  def call
    # http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'text/xml'
    request.body = form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    response = http.request(request)

    # request.set_form_data form_data
    # JSON.parse http.request(request).body
    # request = Net::HTTP::Post.new(uri)
    # request.body = form_data
    # request.content_type = 'text/xml'
    # response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
    response.body
  end

  def form_data
    soap_envelope = Ox::Element.new('SOAP-ENV:Envelope')
    soap_envelope['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
    soap_envelope << header
    soap_envelope << body
    xml_doc << soap_envelope
    Ox.dump(xml_doc)
  end

  private
    def header
      soap_header = Ox::Element.new('SOAP-ENV:Header')
      soap_header['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
      soap_security = Ox::Element.new('wsse:Security')
      soap_security['soap:mustUnderstand'] = 1
      soap_security['xmlns:wsse'] = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
      soap_security['xmlns:soap'] = "http://schemas.xmlsoap.org/soap/envelope/"
      soap_username_token = Ox::Element.new('wsse:UsernameToken')
      soap_username = Ox::Element.new('wsse:Username')
      soap_username << ENV['ROOM_RACCOON_USERNAME']
      soap_password = Ox::Element.new('wsse:Password')
      soap_password['Type'] = "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText"
      soap_password << ENV['ROOM_RACCOON_PASSWORD']
      soap_username_token << soap_username
      soap_username_token << soap_password
      soap_security << soap_username_token
      soap_header << soap_security
      soap_header
    end

    def body
      soap_body = Ox::Element.new('SOAP-ENV:Body')
      soap_body['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
      ota_hotel_res_notif_rq = Ox::Element.new('OTA_HotelResNotifRQ')
      ota_hotel_res_notif_rq['xmlns'] = "http://www.opentravel.org/OTA/2003/05"
      ota_hotel_res_notif_rq['Version'] = "1.0"
      ota_hotel_res_notif_rq['EchoToken'] = SecureRandom.uuid
      ota_hotel_res_notif_rq['ResStatus'] = "commit"
      ota_hotel_res_notif_rq['TimeStamp'] = DateTime.current

      pos = Ox::Element.new('POS')
      source = Ox::Element.new('Source')
      requestor_id = Ox::Element.new('RequestorID')
      requestor_id['Type'] = "22"
      requestor_id['ID'] = "BA1"
      booking_channel = Ox::Element.new('BookingChannel')
      booking_channel['Primary'] = true
      company_name = Ox::Element.new('CompanyName')
      company_name << "Nice2Stay"
      booking_channel << company_name
      source << requestor_id
      source << booking_channel
      pos << source

      hotel_reservations = Ox::Element.new('HotelReservations')
      hotel_reservation = Ox::Element.new('HotelReservation')
      hotel_reservation['CreateDateTime'] = DateTime.current
      unique_id = Ox::Element.new('UniqueID')
      unique_id['Type'] = "14"
      unique_id['ID'] = "66571"

      room_stays = Ox::Element.new("RoomStays")
      room_stay = Ox::Element.new("RoomStay")
      room_types = Ox::Element.new("RoomTypes")
      room_type = Ox::Element.new("RoomType")
      room_type['RoomTypeCode'] = "DLXS"
      room_description = Ox::Element.new("RoomDescription")
      room_description['Name'] = "Deluxe Suite"
      room_type << room_description
      room_types << room_type

      room_rates = Ox::Element.new("RoomRates")
      room_rate = Ox::Element.new("RoomRate")
      room_rate['RoomTypeCode'] = "DLXS"
      room_rate['NumberOfUnits'] = 1
      room_rates << room_rate

      guest_counts = Ox::Element.new("GuestCounts")
      guest_count = Ox::Element.new("GuestCount")
      guest_count['AgeQualifyingCode'] = 10
      guest_count['Count'] = 2
      guest_counts << guest_count

      time_span = Ox::Element.new("TimeSpan")
      time_span['Start'] = "2020-11-12"
      time_span['End'] = "2020-11-14"

      total = Ox::Element.new("Total")
      total['CurrencyCode'] = "EUR"

      basic_property_info = Ox::Element.new("BasicPropertyInfo")
      basic_property_info["HotelCode"] = 5816

      room_stay << room_types
      room_stay << room_rates
      room_stay << guest_counts
      room_stay << time_span
      room_stay << total
      room_stay << basic_property_info
      room_stays << room_stay

      res_guests = Ox::Element.new("ResGuests")
      res_guest = Ox::Element.new("ResGuest")
      profiles = Ox::Element.new("Profiles")
      profile_info = Ox::Element.new("ProfileInfo")
      profile = Ox::Element.new("Profile")
      profile['Profile'] = 1
      customer = Ox::Element.new("Customer")
      person_name = Ox::Element.new("PersonName")
      given_name = Ox::Element.new("GivenName")
      given_name << "John"
      sur_name = Ox::Element.new("SurName")
      sur_name << "Smith"
      person_name << given_name
      person_name << sur_name
      customer << person_name
      profile << customer
      profile_info << profile
      profiles << profile_info
      res_guest << profiles
      res_guests << res_guest

      res_global_info = Ox::Element.new("ResGlobalInfo")
      profiles = Ox::Element.new("Profiles")
      profile_info = Ox::Element.new("ProfileInfo")
      profile = Ox::Element.new("Profile")
      profile['Profile'] = 1
      customer = Ox::Element.new("Customer")
      person_name = Ox::Element.new("PersonName")
      given_name = Ox::Element.new("GivenName")
      given_name << "John"
      sur_name = Ox::Element.new("SurName")
      sur_name << "Smith"
      person_name << given_name
      person_name << sur_name
      customer << person_name
      profile << customer
      profile_info << profile
      profiles << profile_info
      res_global_info << profiles

      hotel_reservation << unique_id
      hotel_reservation << room_stays
      hotel_reservation << res_guests
      hotel_reservation << res_global_info
      hotel_reservations << hotel_reservation
      ota_hotel_res_notif_rq << hotel_reservations
      soap_body << ota_hotel_res_notif_rq
      soap_body
    end

    # def form_data
    #   soap_envelope = Ox::Element.new('SOAP-ENV:Envelope')
    #   soap_envelope['xmlns:SOAP-ENV'] = "http://schemas.xmlsoap.org/soap/envelope/"
    #   soap_envelope << header
    #   soap_envelope << body
    #   soap_envelope
    # end
end
