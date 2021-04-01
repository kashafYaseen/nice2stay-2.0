class RoomRaccoons::CreateAvailabilities
  attr_reader :hotel_id, :lodging_ids, :rr_availabilities

  def self.call(hotel_id:, lodging_ids:, rr_availabilities:)
    new(hotel_id: hotel_id, lodging_ids: lodging_ids, rr_availabilities: rr_availabilities).call
  end

  def initialize(hotel_id:, lodging_ids:, rr_availabilities:)
    @hotel_id = hotel_id
    @lodging_ids = lodging_ids
    @rr_availabilities = rr_availabilities
  end

  def call
    availabilities = []
    lodgings = Lodging.where(id: lodging_ids).includes(room_rates: [:rate_plan, availabilities: :prices])
    rr_availabilities.each do |data|
      dates = (data[:start_date].to_date..data[:end_date].to_date).map(&:to_s)
      stays = data[:stays].length == 2 ? (data[:stays][0]..data[:stays][1]).map(&:to_s) : data[:stays]
      current_lodging = lodgings.find { |lodging| lodging.id == data[:lodging_id].to_i }

      if data[:rate_plan_id].present?
        @room_rates = current_lodging.room_rates.select { |room_rate| room_rate.rate_plan_id == data[:rate_plan_id].to_i }
      else
        @room_rates = current_lodging.room_rates
      end

      @room_rates.each do |current_room_rate|
        dates.each do |date|
          availability = current_room_rate.availabilities.find { |room_rate_availability| room_rate_availability.available_on.to_s == date }
          availability = current_room_rate.availabilities.new(available_on: date, room_rate: current_room_rate, created_at: DateTime.now, updated_at: DateTime.now) unless availability.present?
          availability.rr_minimum_stay = stays.presence || ((current_room_rate.min_stay..current_room_rate.max_stay).map(&:to_s) if availability.rr_minimum_stay.blank?)
          availability.rr_booking_limit = data[:booking_limit] || (current_room_rate.default_booking_limit if availability.rr_booking_limit.zero?)
          check_response = restriction_status(data[:status], data[:restriction])

          if check_response.present? && check_response == 'stop_sell'
            availability.rr_booking_limit = 0
          elsif check_response.present?
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
    prices = prices.flatten
    return if prices.blank?

    Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[minimum_stay] }
    prices.each(&:reindex)
  end

  private
    def restriction_status(status, restriction)
      return unless status.present?

      return 'stop_sell' if status == 'close' && restriction.blank?
      return 'check_out_closed' if status == 'close' && restriction == 'departure'
      return 'check_in_closed' if status == 'close' && restriction == 'arrival'
    end
end
