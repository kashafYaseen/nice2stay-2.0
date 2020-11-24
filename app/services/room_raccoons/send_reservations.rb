class RoomRaccoons::SendReservations
  attr_reader :hotel
  attr_reader :room_types
  attr_reader :booking
  attr_reader :reservations
  attr_reader :uri
  attr_reader :xml_doc

  def self.call(booking)
    self.new(booking).call
  end

  def initialize(booking)
    # @hotel = hotel
    @booking = booking
    @reservations = @booking.reservations.includes(:room_type, :rate_plan)
    # @room_types = room_types
    @uri = URI.parse("https://api.roomraccoon.com/api/")
    @xml_doc = Ox::Document.new
  end

  def call
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'text/xml; charset=utf-8'
    request.body = form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)
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

      ota_hotel_res_notif_rq << get_pos
      ota_hotel_res_notif_rq << get_hotel_reservations
      soap_body << ota_hotel_res_notif_rq
      soap_body
    end


    def get_pos
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
      pos
    end

    def get_hotel_reservations
      hotel_reservations = Ox::Element.new('HotelReservations')
      hotel_reservation = Ox::Element.new('HotelReservation')
      hotel_reservation['CreateDateTime'] = DateTime.current
      unique_id = Ox::Element.new('UniqueID')
      unique_id['Type'] = "14"
      unique_id['ID'] = booking.id
      hotel_reservation << unique_id
      hotel_reservation << room_stays
      hotel_reservation << res_guests
      hotel_reservation << res_global_info
      hotel_reservations << hotel_reservation
      hotel_reservations
    end

    def room_stays
      room_stays = Ox::Element.new("RoomStays")
      reservations.each do |reservation|
        room_stay = Ox::Element.new("RoomStay")
        room_stay << room_types(reservation)
        room_stay << room_rates(reservation)
        room_stay << guest_counts(reservation)
        room_stay << time_span(reservation)
        room_stay << total(reservation)
        room_stay << basic_property_info(reservation)
        room_stay << res_guest_rphs(reservation)
        room_stays << room_stay(reservation)
      end

      room_stays
    end

    def room_types reservation
      room_types = Ox::Element.new("RoomTypes")
      room_type = Ox::Element.new("RoomType")
      room_type['RoomTypeCode'] = reservation.room_type_code
      room_description = Ox::Element.new("RoomDescription")
      room_description['Name'] = reservation.room_type_description
      room_type << room_description
      room_types << room_type
      room_types
    end

    def room_rates reservation
      room_rates = Ox::Element.new("RoomRates")
      room_rate = Ox::Element.new("RoomRate")
      room_rate['RoomTypeCode'] = reservation.room_type_code
      room_rate['RatePlanCode'] = reservation.rate_plan_code
      room_rate['NumberOfUnits'] = 1

      rates = Ox::Element.new("Rates")
      rate = Ox::Element.new("Rate")
      rate["UnitMultiplier"] = 1
      rate["RateTimeUnit"] = "Day"
      rate["EffectiveDate"] = reservation.check_in
      rate["ExpireDate"] = reservation.check_out

      base_rate = Ox::Element.new("Base")
      base_rate["AmountAfterTax"] = reservation.total_price
      base_rate["CurrencyCode"] = "EUR"
      rate << base_rate
      rates << rate
      room_rate << rates
      room_rates << room_rate
      room_rates
    end

    def guest_counts reservation
      guest_counts = Ox::Element.new("GuestCounts")
      total_guests(reservation).each do |guest|
        guest_count = Ox::Element.new("GuestCount")
        guest_count['AgeQualifyingCode'] = guest[0]
        guest_count['Count'] = guest[1]
        guest_counts << guest_count
      end

      guest_counts
    end

    def time_span reservation
      time_span = Ox::Element.new("TimeSpan")
      time_span['Start'] = reservation.check_in
      time_span['End'] = reservation.check_out
      time_span
    end

    def total reservation
      total = Ox::Element.new("Total")
      total['AmountAfterTax'] = reservation.total_price
      total['CurrencyCode'] = "EUR"
      total
    end

    def basic_property_info reservation
      basic_property_info = Ox::Element.new("BasicPropertyInfo")
      basic_property_info["HotelCode"] = reservation.lodging_id
      basic_property_info
    end

    def res_guest_rphs reservation
      res_guest_rphs = Ox::Element.new("ResGuestRPHs")
      res_guest_rph = Ox::Element.new("ResGuestRPH")
      res_guest_rph['RPH'] = reservation.id
      res_guest_rphs << res_guest_rph
      res_guest_rphs
    end

    def res_guests
      res_guests = Ox::Element.new("ResGuests")
      reservations.each do |reservation|
        res_guest = Ox::Element.new("ResGuest")
        res_guest['ResGuestRPH'] = reservation.id
        res_guest << get_profiles
        res_guests << res_guest
      end

      res_guests
    end

    def res_global_info
      res_global_info = Ox::Element.new("ResGlobalInfo")
      hotel_reservation_ids = Ox::Element.new("HotelReservationIDs")
      hotel_reservation_id = Ox::Element.new("HotelReservationID")
      hotel_reservation_id['ResID_Type'] = 14
      hotel_reservation_id['ResID_Value'] = booking.id
      hotel_reservation_ids << hotel_reservation_id

      total = Ox::Element.new("Total")
      total['AmountAfterTax'] = booking.total_payment
      total['CurrencyCode'] = "EUR"

      res_global_info << hotel_reservation_ids
      res_global_info << total
      res_global_info << get_profiles
      res_global_info
    end


    def total_guests reservation
      guest_count = []
      guest_count << ["10", reservation.adults] if reservation.adults > 0
      guest_count << ["8", reservation.children] if reservation.children > 0
      guest_count << ["7", reservation.infants] if reservation.infants > 0
      guest_count
    end

    def get_profiles
      profiles = Ox::Element.new("Profiles")
      profile_info = Ox::Element.new("ProfileInfo")
      profile = Ox::Element.new("Profile")
      profile['ProfileType'] = 1

      customer = Ox::Element.new("Customer")
      person_name = Ox::Element.new("PersonName")
      given_name = Ox::Element.new("GivenName")
      given_name << booking.user_first_name
      sur_name = Ox::Element.new("SurName")
      sur_name << booking.user_last_name

      person_name << given_name
      person_name << sur_name
      customer << person_name
      profile << customer
      profile_info << profile
      profiles << profile_info
      profiles
    end
end
