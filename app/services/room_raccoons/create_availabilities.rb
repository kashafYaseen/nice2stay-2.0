class RoomRaccoons::CreateAvailabilities
  attr_reader :hotel_id,
              :lodging_ids,
              :rr_availabilities

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
      stays = default_stay(data)
      current_lodging = lodgings.find { |lodging| lodging.id == data[:lodging_id].to_i }
      current_room_rate = current_lodging.room_rates.find { |room_rate| room_rate.rate_plan_id == data[:rate_plan_id]&.to_i }
      next if current_room_rate.blank?

      dates.each do |date|
        availability = current_room_rate.availabilities.find { |room_rate_availability| room_rate_availability.available_on.to_s == date } ||
                        current_room_rate.availabilities.new(available_on: date, room_rate: current_room_rate, created_at: DateTime.now, updated_at: DateTime.now)
        availability.rr_minimum_stay = minimum_stay(availability, data, stays, current_room_rate)
        availability.rr_booking_limit = data[:booking_limit] || current_room_rate.default_booking_limit if availability.rr_booking_limit.zero? || data[:booking_limit].present?
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

    return unless availabilities.present?

    Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[rr_booking_limit rr_check_in_closed rr_check_out_closed rr_minimum_stay ] }
    prices = []
    availabilities.each do |availability|
      next if availability.new_record?

      availability.prices.each { |price| price.minimum_stay = availability.rr_minimum_stay }
      prices << availability.prices
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

    def default_stay params
      return [] if params[:min_stay].blank? && params[:max_stay].blank?
      return (1..45).map(&:to_s) if params[:min_stay].blank? && params[:max_stay].to_i > 45
      return (params[:min_stay].to_i..45).map(&:to_s) if params[:min_stay].present? && params[:max_stay].to_i > 45
      return (1..params[:max_stay].to_i).map(&:to_s) if params[:min_stay].blank? && params[:max_stay].to_i < 45
      return (params[:min_stay].to_i..45).map(&:to_s) if params[:min_stay].present? && params[:max_stay].blank?

      (params[:min_stay].to_i..params[:max_stay].to_i).map(&:to_s)
    end

    def minimum_stay availability, params, stays, room_rate
      return stays.presence || (room_rate.min_stay..room_rate.max_stay).map(&:to_s) if availability.rr_minimum_stay.blank? || (params[:min_stay].present? && params[:max_stay].present?)
      return (availability.rr_minimum_stay[0].to_i..stays[-1].to_i).map(&:to_s) if params[:max_stay].present?
      return (stays[0].to_i..availability.rr_minimum_stay[-1].to_i).map(&:to_s) if params[:min_stay].present?
    end
end
