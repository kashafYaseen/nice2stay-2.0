class RoomRaccoons::ValidateAvailabilities
  attr_reader :body, :hotel_id, :availabilities

  def initialize(body:, hotel_id:)
    @body = body
    @availabilities = []
    @hotel_id = hotel_id
  end

  def self.call(body:, hotel_id:)
    new(body: body, hotel_id: hotel_id).call
  end

  def call
    begin
      if @body['availstatusmessages']['availstatusmessage'].is_a?(Array)
        @body['availstatusmessages']['availstatusmessage'].each do |avail_status_message|
          availabilities << parse_data(avail_status_message)
        end
      else
        availabilities << parse_data(@body['availstatusmessages']['availstatusmessage'])
      end

      Rails.logger.info "PARSED AVAILABILITIES ===============================>>>>>>>>>> #{availabilities}"
      rooms = RoomType.where(parent_lodging_id: hotel_id, code: room_type_codes)
      return false if rooms.size.zero?

      Rails.logger.info '===============================>>>>>>>>>>In Availabilities JOB'
      RrCreateAvailabilitiesJob.perform_later(
        hotel_id: hotel_id,
        room_type_codes: room_type_codes,
        rr_availabilities: availabilities
      )
      true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Availabilities============>: #{ e }"
      false
    end
  end

  private
    def parse_data data
      booking_limit = data['bookinglimit']
      status_application_control = data['statusapplicationcontrol']
      if status_application_control.present?
        @start = status_application_control['start']
        @end = status_application_control['end']
        @room_type_code = status_application_control['invtypecode']
        @rate_plan_code = status_application_control['rateplancode']
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
          length_of_stays['lengthofstay'].each do |length_of_stay|
            @stays << length_of_stay['time']
          end
        else
          @stays << length_of_stays['lengthofstay']['time']
        end
      end

      {
        start_date: @start,
        end_date: @end,
        room_type_code: @room_type_code,
        rate_plan_code: @rate_plan_code,
        status: @status&.downcase,
        restriction: @restriction&.downcase,
        stays: @stays&.sort,
        booking_limit: booking_limit
      }
    end

    def room_type_codes
      availabilities.map { |data| data[:room_type_code] }.uniq
    end

    def rate_plan_codes
      availabilities.map { |data| data[:rate_plan_code] }.uniq
    end
end
