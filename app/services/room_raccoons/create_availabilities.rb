class RoomRaccoons::CreateAvailabilities
  attr_reader :body
  attr_reader :hotel

  def initialize(body, hotel)
    @body = body
    @hotel = hotel
  end

  def self.call(body, hotel)
    self.new(body, hotel).call
  end

  def call
    begin
      @body['OTA_HotelAvailNotifRQ']['AvailStatusMessages']['AvailStatusMessage'].each do |avail_status_message|
        start_date, end_date, room_type_code, status, restriction, stays = parse_data(avail_status_message)

        num_of_availabilities = (end_date - start_date).to_i + 1
        rooms = hotel.room_types.find_by(code: room_type_code).child_lodgings
        rooms.each do |room|
          num_of_availabilities.times do |index|
            availability = room.availabilities.find_or_create_by(available_on: (start_date + index.day))
            res = restriction_status(status, restriction)

            if res.present? || stays.present?
              availability.prices.find_or_create_by(
                rr_check_in_closed: "#{ res == "check_in_closed" ? true : false }",
                rr_check_out_closed: "#{ res == "check_out_closed" ? true : false }",
                minimum_stay: stays
              )
            end
          end
        end
      end
      return true
    rescue Exception => e
      return false
    end
  end

  private
    def parse_data(data)
      status_application_control = data['StatusApplicationControl']
      if status_application_control.present?
        @start = status_application_control["Start"]&.to_date
        @end = status_application_control["End"]&.to_date
        @room_type_code = status_application_control["InvTypeCode"]
      end

      restriction_status = data['RestrictionStatus']
      if restriction_status.present?
        @status = restriction_status['Status']
        @restriction = restriction_status['Restriction']
      end

      length_of_stays = data['LengthsOfStay']
      if length_of_stays.present?
        @stays = []
        length_of_stays["LengthOfStay"].each do |length_of_stay|
          @stays << length_of_stay["Time"]
        end
      end

      return @start, @end, @room_type_code, @status, @restriction, @stays&.sort
    end

    def restriction_status(status, restriction)
      return "check_out_closed" if status == "Close" && restriction == "Departure"
      return "check_in_closed" if status == "Close" && restriction == "Arrival"
    end
end
