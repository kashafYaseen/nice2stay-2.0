class RoomRaccoons::CreateAvailabilities
  attr_reader :hotel_id, :room_type_codes, :rr_availabilities

  def self.call(hotel_id:, room_type_codes:, rr_availabilities:)
    new(hotel_id: hotel_id, room_type_codes: room_type_codes, rr_availabilities: rr_availabilities).call
  end

  def initialize(hotel_id:, room_type_codes:, rr_availabilities:)
    @hotel_id = hotel_id
    @room_type_codes = room_type_codes
    @rr_availabilities = rr_availabilities
  end

  def call
    availabilities = []
    room_types = RoomType.includes(room_rates: [:rate_plan, availabilities: :prices]).where(parent_lodging_id: hotel_id, room_types: { code: room_type_codes })
    rr_availabilities.each do |data|
      dates = (data[:start_date].to_date..data[:end_date].to_date).map(&:to_s)
      stays = data[:stays].length == 2 ? (data[:stays][0]..data[:stays][1]).map(&:to_s) : data[:stays]
      current_room_type = room_types.find { |room_type| room_type.code == data[:room_type_code] }
      current_room_rate = current_room_type.room_rates.find { |room_rate| room_rate.rate_plan_code == data[:rate_plan_code] }

      dates.each do |date|
        availability = current_room_rate.availabilities.find { |room_rate_availability| room_rate_availability.available_on.to_s == date }
        availability = current_room_rate.availabilities.new(available_on: date, room_rate: current_room_rate, created_at: DateTime.now, updated_at: DateTime.now) unless availability.present?
        availability.rr_minimum_stay = stays
        availability.rr_booking_limit = data[:booking_limit]
        check_response = restriction_status(data[:status], data[:restriction])
        if check_response.present?
          check_response == 'check_in_closed' ? availability.rr_check_in_closed = true : availability.rr_check_out_closed = true
        end

        availability_index = availabilities.index { |avail| avail.available_on == availability.available_on && avail.room_rate_id == availability.room_rate_id }
        if availability_index.present?
          availabilities[availability_index] = availability
        elsif availability.new_record? || availability.changed?
          availabilities << availability
        end
      end
    end

    return unless availabilities.present?

    Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[rr_booking_limit rr_check_in_closed rr_check_out_closed rr_minimum_stay ] }
    prices = []
    availabilities.each do |availability|
      unless availability.new_record?
        availability.prices.each { |price| price.minimum_stay = availability.rr_minimum_stay }
        prices << availability.prices
      end
    end

    return unless prices.present?

    prices = prices.flatten
    Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[minimum_stay] }
    prices.each(&:reindex)
  end

  private
    def restriction_status(status, restriction)
      return 'check_out_closed' if status == 'close' && restriction == 'departure'
      return 'check_in_closed' if status == 'close' && restriction == 'arrival'
    end
end
