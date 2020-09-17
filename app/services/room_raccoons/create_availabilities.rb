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
        start_date, end_date, room_id, rate_plan_code, status, restriction, stays = parse_data(avail_status_message)

        dates = (end_date..start_date).map(&:to_s)
        stays = stays.length == 2 ? (stays[0]..stays[1]).map(&:to_s) : stays
        room = hotel.lodging_children.find(room_id)
        dates.each do |date|
          availability = room.availabilities.find_or_create_by(available_on: date)

          price = availability.prices.find_or_initialize_by(rr_rate_plan_code: rate_plan_code) { |price|  price.minimum_stay = stays }
          price.save

          check_response = restriction_status(status, restriction)
          if check_response.present?
            rule = room.rules.find_or_initialize_by(start_date: start_date, end_date: end_date) { |rule| rule.minimum_stay = stays }
            check_response == "check_in_closed" ? rule.rr_check_in_closed = true : rule.rr_check_out_closed = true
            rule.save
          end
        end
      end
      return true
    rescue
      return false
    end
  end

  private
    def parse_data(data)
      status_application_control = data['StatusApplicationControl']
      if status_application_control.present?
        @start = status_application_control["Start"]&.to_date
        @end = status_application_control["End"]&.to_date
        @room_id = status_application_control["InvTypeCode"]
        @rate_plan_code = status_application_control["RatePlanCode"]
      end

      restriction_status = data['RestrictionStatus']
      if restriction_status.present?
        @status = restriction_status['Status']
        @restriction = restriction_status['Restriction']
      end

      length_of_stays = data['LengthsOfStay']
      @stays = []
      if length_of_stays.present?
        length_of_stays["LengthOfStay"].each do |length_of_stay|
          @stays << length_of_stay["Time"]
        end
      end

      return @start, @end, @room_id, @rate_plan_code, @status, @restriction, @stays&.sort
    end

    def restriction_status(status, restriction)
      return "check_out_closed" if status == "Close" && restriction == "Departure"
      return "check_in_closed" if status == "Close" && restriction == "Arrival"
    end
end
