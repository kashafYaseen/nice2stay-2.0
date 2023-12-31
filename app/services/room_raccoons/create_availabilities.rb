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
      room_rates = lodging_room_rates(current_lodging, data)
      next if room_rates.blank?

      room_rates.each do |current_room_rate|
        dates.each do |date|
          availability = current_room_rate.availabilities.find { |room_rate_availability| room_rate_availability.available_on.to_s == date } ||
                          current_room_rate.availabilities.new(available_on: date, room_rate: current_room_rate, created_at: DateTime.now, updated_at: DateTime.now)
          availability.minimum_stay = minimum_stay(availability, data, stays, current_room_rate) if data[:min_stay].present? || data[:max_stay].present?
          availability.booking_limit = data[:booking_limit] || current_room_rate.default_booking_limit if availability.booking_limit.zero? || data[:booking_limit].present?
          restriction_status(data[:status], data[:restriction], availability)

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

    Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[booking_limit check_in_closed check_out_closed minimum_stay ] }
    prices = []
    availabilities.each do |availability|
      next if availability.new_record?

      availability.prices.each { |price| price.minimum_stay = availability.minimum_stay }
      prices << availability.prices
    end

    prices = prices.flatten
    return if prices.blank?

    Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[minimum_stay] }
    prices.each(&:reindex)
    lodgings.reindex
    Lodging.flush_cached_searched_data
  end

  private
    def restriction_status status, restriction, availability
      return unless status.present?
      return availability.booking_limit = 0 if status == 'close' && restriction.blank?
      return availability.check_out_closed = (status == 'close') if restriction == 'departure'
      availability.check_in_closed = (status == 'close') if restriction == 'arrival'
    end

    def default_stay params
      return (1..45).map(&:to_s) if params[:min_stay].blank? && params[:max_stay].to_i > 45
      return (params[:min_stay].to_i..45).map(&:to_s) if params[:min_stay].present? && params[:max_stay].to_i > 45
      return (1..params[:max_stay].to_i).map(&:to_s) if params[:min_stay].blank? && params[:max_stay].to_i < 45
      return (params[:min_stay].to_i..45).map(&:to_s) if params[:min_stay].present? && params[:max_stay].blank?

      (params[:min_stay].to_i..params[:max_stay].to_i).map(&:to_s)
    end

    def minimum_stay availability, params, stays, room_rate
      return stays.presence || (room_rate.min_stay..room_rate.max_stay).map(&:to_s) if availability.minimum_stay.blank? || (params[:min_stay].present? && params[:max_stay].present?)
      return (availability.min_stay.to_i..stays[-1].to_i).map(&:to_s) if params[:max_stay].present?
      return (stays[0].to_i..availability.max_stay.to_i).map(&:to_s) if params[:min_stay].present?
    end

    def lodging_room_rates lodging, params
      return lodging.room_rates.select { |room_rate| room_rate.rate_plan_id == params[:rate_plan_id].to_i } if params[:rate_plan_id].present?

      lodging.room_rates
    end
end
