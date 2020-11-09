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

      rooms = hotel.lodging_children.joins(:room_type).distinct.where(room_types: { code: parsed_data.map {|data| data[:room_type_code] }.uniq })
      return false if rooms.size == 0
      RrCreateAvailabilitiesJob.perform_later hotel, parsed_data
      return true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Availabilities============>: #{ e }"
      return false
    end
  end

  private
    def parse_data data
      status_application_control = data['statusapplicationcontrol']
      if status_application_control.present?
        @start = status_application_control["start"]
        @end = status_application_control["end"]
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
end
