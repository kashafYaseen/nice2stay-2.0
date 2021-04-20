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
      return false if Lodging.where(id: lodging_ids).count.zero?

      Rails.logger.info '===============================>>>>>>>>>>In Availabilities JOB'
      RrCreateAvailabilitiesJob.perform_later(
        hotel_id: hotel_id,
        lodging_ids: lodging_ids,
        rr_availabilities: availabilities
      )
      true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Availabilities============>: #{e}"
      false
    end
  end

  private
    def parse_data data
      response = {}
      response[:booking_limit] = data['bookinglimit'] if data['bookinglimit'].present?
      status_application_control = data['statusapplicationcontrol']
      if status_application_control.present?
        response[:start_date] = status_application_control['start']
        response[:end_date] = status_application_control['end']
        response[:lodging_id] = status_application_control['invtypecode']
        response[:rate_plan_id] = status_application_control['rateplancode']
      end

      restriction_status = data['restrictionstatus']
      if restriction_status.present?
        response[:status] = restriction_status['status']&.downcase
        response[:restriction] = restriction_status['restriction']&.downcase
      end

      length_of_stays = data['lengthsofstay']
      @stays = []
      if length_of_stays.present?
        if length_of_stays['lengthofstay'].is_a?(Array)
          length_of_stays['lengthofstay'].each do |length_of_stay|
            response[:min_stay] = length_of_stay['time'] if length_of_stay['minmaxmessagetype'] == 'SetMinLOS'
            response[:max_stay] = length_of_stay['time'] if length_of_stay['minmaxmessagetype'] == 'SetMaxLOS'
          end
        else
          length_of_stay = length_of_stays['lengthofstay']
          response[:min_stay] = length_of_stay['time'] if length_of_stay['minmaxmessagetype'] == 'SetMinLOS'
          response[:max_stay] = length_of_stay['time'] if length_of_stay['minmaxmessagetype'] == 'SetMaxLOS'
        end
      end

      response
    end

    def lodging_ids
      availabilities.map { |data| data[:lodging_id] }.uniq
    end

    def rate_plan_ids
      availabilities.map { |data| data[:rate_plan_id] }.uniq
    end
end
