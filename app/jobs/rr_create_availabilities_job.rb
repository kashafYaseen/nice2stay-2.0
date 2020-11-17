class RrCreateAvailabilitiesJob < ApplicationJob
  queue_as :default

  def perform(hotel, parsed_data)
    hotel_room_types = hotel.room_types.includes(:rate_plans, availabilities: :rate_plan).where(room_types: { code: parsed_data.map {|data| data[:room_type_code] }.uniq })

    parsed_data.each do |data|
      availabilities = []
      dates = (data[:start_date]..data[:end_date]).map(&:to_s)
      stays = data[:stays].length == 2 ? (data[:stays][0]..data[:stays][1]).map(&:to_s) : data[:stays]
      room_types = hotel_room_types.map { |room_type| room_type if room_type.code == data[:room_type_code] }.delete_if { |room_type| room_type.blank? }

      room_types.each do |room_type|
        rate_plan = room_type.rate_plans.map { |rate_plan| rate_plan if rate_plan.code == data[:rate_plan_code] }.delete_if { |rate_plan| rate_plan.blank? }&.first
        dates.each do |date|
          @availability = room_type.availabilities.map { |availability| availability if availability.available_on.to_s == date && availability.rate_plan_code == data[:rate_plan_code] }.delete_if { |availability| availability.blank? }&.first
          @availability = room_type.availabilities.new(available_on: date, rate_plan: rate_plan, created_at: DateTime.now, updated_at: DateTime.now) unless @availability.present?
          @availability.rr_minimum_stay = stays
          @availability.rr_booking_limit = data[:booking_limit]
          check_response = restriction_status(data[:status], data[:restriction])
          if check_response.present?
            check_response == "check_in_closed" ? @availability.rr_check_in_closed = true : @availability.rr_check_out_closed = true
          end

          availabilities << @availability if @availability.new_record? || @availability.changed?
        end
      end

      Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: [ :rr_booking_limit, :rr_check_in_closed, :rr_check_out_closed, :rr_minimum_stay ] } if availabilities.present?
    end
  end

  private
    def restriction_status(status, restriction)
      return "check_out_closed" if status == "close" && restriction == "departure"
      return "check_in_closed" if status == "close" && restriction == "arrival"
    end
end
