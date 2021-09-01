class RoomRaccoons::CreatePrices
  attr_reader :hotel_id,
              :lodging_ids,
              :rate_plan_ids,
              :rr_prices

  def self.call(hotel_id:, lodging_ids:, rate_plan_ids:, rr_prices:)
    new(hotel_id: hotel_id, lodging_ids: lodging_ids, rate_plan_ids: rate_plan_ids, rr_prices: rr_prices).call
  end

  def initialize(hotel_id:, lodging_ids:, rate_plan_ids:, rr_prices:)
    @hotel_id = hotel_id
    @lodging_ids = lodging_ids
    @rate_plan_ids = rate_plan_ids
    @rr_prices = rr_prices
  end

  def call
    lodgings = Lodging.where(id: lodging_ids).includes(room_rates: [{ availabilities: :prices }, :rate_plan])
    new_availabilities = []

    rr_prices.each do |rr_price|
      dates = (rr_price[:start_date].to_date..rr_price[:end_date].to_date).map(&:to_s)
      current_lodging = lodgings.find { |lodging| lodging.id == rr_price[:lodging_id].to_i }
      current_room_rate = current_lodging.room_rates.find { |room_rate| room_rate.rate_plan_id == rr_price[:rate_plan_id]&.to_i }
      next if current_room_rate.blank?

      availabilities = find_or_create_availabilities(current_room_rate, dates).flatten
      new_availabilities << availabilities unless availabilities_exists?(new_availabilities.flatten, availabilities)

      availabilities.each do |availability|
        rr_price[:rates].each do |rate|
          add_prices_for rate, availability
        end

        next unless rr_price[:additional_amounts].present?

        rr_price[:additional_amounts].each do |additional_amount|
          add_prices_for additional_amount, availability, true
        end
      end
    end

    new_availabilities = new_availabilities.flatten
    return unless new_availabilities.present?

    availabilities = new_availabilities.select do |availability|
      availability.new_record? || availability.changed?
    end

    Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on] }
    prices = []
    new_availabilities.each do |availability|
      availability.prices.each { |price| price.availability_id = availability.id }
      prices << availability.prices
    end

    prices = prices.flatten
    return unless prices.present?

    Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[amount children infants adults minimum_stay rr_additional_amount_flag] }
    prices.each(&:reindex)
    Lodging.flush_cached_searched_data
    lodgings.reindex
  end

  private
    def find_or_create_availabilities room_rate, dates
      availabilities = []
      dates.each do |date|
        availability = room_rate.availabilities.find { |avail| avail.available_on.to_s == date } || room_rate.availabilities.new(available_on: date)
        availabilities << availability
      end

      availabilities
    end

    def availabilities_exists? new_availabilities, availabilities
      dates = availabilities.map(&:available_on)
      room_rate_ids = availabilities.map(&:room_rate_id)
      availability_index = new_availabilities.index do |new_availability|
        dates.include?(new_availability.available_on) &&
          room_rate_ids.include?(new_availability.room_rate_id)
      end

      availability_index.present?
    end

    def add_prices_for(params, availability, additional_price = false)
      return set_base_price(params, availability) unless additional_price

      set_additional_price(params, availability)
    end

    def set_base_price(params, availability)
      prices = availability.prices.reject(&:rr_additional_amount_flag)
      price = search_price(prices, params)

      price ||= availability.prices.new(created_at: DateTime.now, updated_at: DateTime.now)
      price.amount = params[:amount] if params[:amount].present?
      price.minimum_stay = availability.minimum_stay
      price.rr_additional_amount_flag = false
      num_of_guests = params[:guests].presence || (price.new_record? && '999')
      return unless num_of_guests.present?

      set_guests price, params, num_of_guests
    end

    def set_additional_price(params, availability)
      prices = availability.prices.select(&:rr_additional_amount_flag)
      additional_price = search_price(prices, params, true)
      additional_price ||= availability.prices.new(created_at: DateTime.now, updated_at: DateTime.now)
      additional_price.amount = params[:amount].to_f
      additional_price.minimum_stay = availability.minimum_stay
      additional_price.rr_additional_amount_flag = true
      set_guests additional_price, params, '1'
    end

    def search_price prices, params, additional_guest_amount = false
      return prices.find { |price| additional_price_condition_with price, params } if additional_guest_amount
      return prices.find { |price| price.adults == [params[:guests] || '999'] } unless params[:age_qualifying_code].present?

      prices.find { |price| base_price_condition_with price, params }
    end

    def base_price_condition_with price, params
      !price.rr_additional_amount_flag &&
        (params[:age_qualifying_code] == '10' && price.adults == [params[:guests] || '999']) ||
        (params[:age_qualifying_code] == '8' && price.children == [params[:guests] || '999'])
    end

    def additional_price_condition_with price, params
      price.rr_additional_amount_flag &&
        (params[:age_qualifying_code] == '10' && price.adults == ['1'] && price.children == ['0']) ||
        (params[:age_qualifying_code] == '8' && price.adults == ['0'] && price.children == ['1'])
    end

    def set_guests price, params, guests
      case params[:age_qualifying_code]
      when '8'
        price.children = [guests]
        price.adults = ['0']
      else
        price.adults = [guests]
        price.children = ['0']
      end

      price.infants = ['0']
    end
end
