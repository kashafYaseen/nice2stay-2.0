class RoomRaccoons::CreatePrices
  attr_reader :hotel_id, :room_type_codes, :rate_plan_codes, :rr_prices

  def self.call(hotel_id:, room_type_codes:, rate_plan_codes:, rr_prices:)
    new(hotel_id: hotel_id, room_type_codes: room_type_codes, rate_plan_codes: rate_plan_codes, rr_prices: rr_prices).call
  end

  def initialize(hotel_id:, room_type_codes:, rate_plan_codes:, rr_prices:)
    @hotel_id = hotel_id
    @room_type_codes = room_type_codes
    @rate_plan_codes = rate_plan_codes
    @rr_prices = rr_prices
  end

  def call
    hotel_room_types = RoomType.includes(availabilities: [:rate_plan, { cleaning_costs: :availability }, { prices: :availability }]).where(parent_lodging_id: hotel_id).by_codes room_type_codes, rate_plan_codes
    new_availabilities = []

    rr_prices.each do |rr_price|
      dates = (rr_price[:start_date].to_date..rr_price[:end_date].to_date).map(&:to_s)
      current_room_type = hotel_room_types.find { |room_type| room_type.code == rr_price[:room_type_code] }
      current_room_rate = current_room_type.room_rates.find { |room_rate| room_rate.rate_plan_code == rr_price[:rate_plan_code] }
      availabilities = find_or_create_availabilities(current_room_rate, dates)
      new_availabilities << availabilities unless availabilities_exists?(new_availabilities.flatten, availabilities)

      availabilities.flatten.each do |availability|
        prices = availability.prices
        rr_price[:rates].each do |rate|
          if rate[:age_qualifying_code].present?
            @price = prices.find { |price|
              (rate[:age_qualifying_code] == '7' && price.infants == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == '8' && price.children == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == '10' && price.adults == [rate[:guests]])
            }
          else
            @price = prices.find { |price| !(price.children.present? || price.adults.present? || price.infants.present?) }
          end

          @price ||= availability.prices.new(created_at: DateTime.now, updated_at: DateTime.now)
          @price.amount = rate[:amount]

          case rate[:age_qualifying_code]
          when '7'
            @price.infants = [rate[:guests]]
          when '8'
            @price.children = [rate[:guests]]
          else
            @price.adults = [rate[:guests]]
          end

          @price.minimum_stay = availability.rr_minimum_stay
        end

        next unless rr_price[:additional_amounts].present?

        cleaning_costs = availability.cleaning_costs
        rr_price[:additional_amounts].each do |additional_amount|
          @cleaning_cost = cleaning_costs.find { |cleaning_cost|
            (additional_amount[:age_qualifying_code] == '7' && cleaning_cost.name == 'Infants') ||
              (additional_amount[:age_qualifying_code] == '8' && cleaning_cost.name == 'Children') ||
              (additional_amount[:age_qualifying_code] == '10' && cleaning_cost.name == 'Adults')
          }

          @cleaning_cost ||= cleaning_costs.new(created_at: DateTime.now, updated_at: DateTime.now)
          @cleaning_cost.fixed_price = additional_amount[:amount]

          case additional_amount[:age_qualifying_code]
          when '7'
            @cleaning_cost.name = 'Infants'
          when '8'
            @cleaning_cost.name = 'Children'
          else
            @cleaning_cost.name = 'Adults'
          end
        end
      end
    end

    if new_availabilities.present?
      availabilities = new_availabilities.flatten.select do |availability|
        availability.new_record? || availability.changed?
      end
      Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on] }
      prices = []
      cleaning_costs = []

      new_availabilities.flatten.each do |availability|
        availability.prices.each { |price| price.availability_id = availability.id }
        availability.cleaning_costs.each { |cleaning_cost| cleaning_cost.availability_id = availability.id }
        prices << availability.prices
        cleaning_costs << availability.cleaning_costs
      end

      prices = prices.flatten
      Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[amount children infants adults minimum_stay] } if prices.present?
      prices.each(&:reindex)

      cleaning_costs = cleaning_costs.flatten
      CleaningCost.import cleaning_costs, batch: 150, on_duplicate_key_update: { columns: %i[fixed_price name] } if cleaning_costs.present?
    end
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
end
