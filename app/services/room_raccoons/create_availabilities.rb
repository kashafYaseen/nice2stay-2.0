class RoomRaccoons::CreateAvailabilities
  attr_reader :body
  attr_reader :hotel

  def initialize(body, hotel_id)
    @body = body
    @hotel = Lodging.find_by(id: hotel_id)
  end

  def self.call(body, hotel_id)
    self.new(body, hotel_id).call
  end

  def call
    begin
      parsed_data = []
      if @body['availstatusmessages']['availstatusmessage'].is_a?(Array)
        @body['availstatusmessages']['availstatusmessage'].each do |avail_status_message|
          parsed_data << parse_data(avail_status_message)
        end
      else
        parsed_data << parse_data(@body['availstatusmessages']['availstatusmessage'])
      end

      create_availabilities parsed_data
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

      return {
        start_date: @start,
        end_date: @end,
        room_type_code: @room_type_code&.upcase,
        status: @status&.upcase,
        restriction: @restriction&.downcase,
        stays: @stays&.sort
      }
    end

    def restriction_status(status, restriction)
      return "check_out_closed" if status == "close" && restriction == "departure"
      return "check_in_closed" if status == "close" && restriction == "arrival"
    end

    def create_availabilities parsed_data
      rooms = hotel.lodging_children.joins(:room_type).distinct.includes(:availabilities, :rules).where(room_types: { code: parsed_data.map {|data| data[:room_type_code].uniq! } })
      availabilities = []
      rules = []

      parsed_data.each do |data|
        dates = (data[:start_date]..data[:end_date]).map(&:to_s)
        stays = data[:stays].length == 2 ? (data[:stays][0]..data[:stays][1]).map(&:to_s) : data[:stays]
        rooms.each do |room|
          available_on_dates = room.availabilities.pluck(:available_on)
          dates.each do |date|
            availabilities << room.availabilities.new(available_on: date, created_at: DateTime.now, updated_at: DateTime.now) unless available_on_dates.include?(date.to_date)
          end

          check_response = restriction_status(data[:status], data[:restriction])
          if stays.present? || check_response.present?
            rule_index = room.rules.find_index {|rule| rule.start_date == data[:start_date] && rule.end_date == data[:end_date] }
            rule = rule_index.present? ?
                    room.rules[rule_index] :
                    room.rules.new(start_date: data[:start_date], end_date: data[:end_date], created_at: DateTime.now, updated_at: DateTime.now)

            if check_response.present?
              check_response == "check_in_closed" ? rule.rr_check_in_closed = true : rule.rr_check_out_closed = true
            end
            rule.minimum_stay = stays
            rules << rule if rule.new_record? || rule.changed?
          end
        end
      end

      Availability.import availabilities, batch_size: 150 if availabilities.present?
      Rule.import rules, batch: 150, on_duplicate_key_update: { columns: [ :rr_check_in_closed, :rr_check_out_closed, :start_date, :end_date, :minimum_stay ] } if rules.present?
    end
end
