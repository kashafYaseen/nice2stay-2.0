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
      if @body['availstatusmessages']['availstatusmessage'].is_a?(Array)
        @body['availstatusmessages']['availstatusmessage'].each do |avail_status_message|
          create_availabilities avail_status_message
        end
      else
        create_availabilities @body['availstatusmessages']['availstatusmessage']
      end
      return true
    rescue
      return false
    end
  end

  private
    def parse_data data
      status_application_control = data['statusapplicationcontrol']
      if status_application_control.present?
        @start = status_application_control["start"]&.to_date
        @end = status_application_control["end"]&.to_date
        @room_type_code = status_application_control["invtypecode"]
        @rate_plan_code = status_application_control["rateplancode"]
      end

      restriction_status = data['restrictionstatus']
      if restriction_status.present?
        @status = restriction_status['status']
        @restriction = restriction_status['restriction']
      end

      length_of_stays = data['lengthsofstay']
      @stays = []
      if length_of_stays.present?
        if length_of_stays['lengthofstay'].is_a?(Array)
          length_of_stays["lengthofstay"].each do |length_of_stay|
            @stays << length_of_stay["time"]
          end
        else
          @stays << length_of_stays['lengthofstay']["time"]
        end
      end

      return @start, @end, @room_type_code&.upcase, @rate_plan_code&.upcase, @status&.downcase, @restriction&.downcase, @stays&.sort
    end

    def restriction_status(status, restriction)
      return "check_out_closed" if status == "close" && restriction == "departure"
      return "check_in_closed" if status == "close" && restriction == "arrival"
    end

    def create_availabilities avail_status_message
      start_date, end_date, room_type_code, rate_plan_code, status, restriction, stays = parse_data(avail_status_message)

      dates = (start_date..end_date).map(&:to_s)
      stays = stays.length == 2 ? (stays[0]..stays[1]).map(&:to_s) : stays

      if rate_plan_code.present?
        @rooms = hotel.room_types.find_by(code: room_type_code).child_lodgings.by_rate_code(rate_plan_code.upcase).includes(:availabilities, :rules)
      else
        @rooms = hotel.room_types.find_by(code: room_type_code).child_lodgings.includes(:availabilities, :rules)
      end

      availabilities = []
      rules = []
      @rooms.each do |room|
        available_on_dates = room.availabilities.pluck(:available_on)

        dates.each do |date|
          unless available_on_dates.include?(date.to_date)
            availabilities << room.availabilities.new(available_on: date, created_at: DateTime.now, updated_at: DateTime.now)
          end
        end

        check_response = restriction_status(status, restriction)
        if check_response.present?
          rule_index = room.rules.find_index {|rule| rule.start_date == start_date.to_date && rule.end_date == end_date.to_date }
          if rule_index.present?
            rule = room.rules[rule_index]
            check_response == "check_in_closed" ? rule.rr_check_in_closed = true : rule.rr_check_out_closed = true
            rule.save
          else
            rule = room.rules.new(start_date: start_date, end_date: end_date, minimum_stay: stays, created_at: DateTime.now, updated_at: DateTime.now)
            check_response == "check_in_closed" ? rule.rr_check_in_closed = true : rule.rr_check_out_closed = true
            rules << rule
          end
        end
      end

      if availabilities.present?
        Availability.import availabilities, batch_size: 150
      end

      if rules.present?
        Rule.import rules, batch: 150
      end
    end
end
