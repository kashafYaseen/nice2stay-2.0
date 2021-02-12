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
    new_prices = []
    new_cleaning_costs = []
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
          price_index = new_prices.index do |new_price|
            new_price.availability == @price.availability &&
              (new_price.infants == @price.infants || new_price.children == @price.children || new_price.adults == @price.adults || new_price.minimum_stay == @price.minimum_stay)
          end

          if price_index.present?
            new_prices[price_index] = @price
          elsif @price.new_record? || @price.changed?
            new_prices << @price
          end
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

          cleaning_cost_index = new_cleaning_costs.index do |new_cleaning_cost|
            new_cleaning_cost.availability == @cleaning_cost.availability &&
              new_cleaning_cost.name == @cleaning_cost.name
          end

          if cleaning_cost_index.present?
            new_cleaning_costs[cleaning_cost_index] = @cleaning_cost
          elsif @cleaning_cost.new_record? || @cleaning_cost.changed?
            new_cleaning_costs << @cleaning_cost
          end
        end
      end
    end

    if new_availabilities.present?
      new_availabilities = new_availabilities.flatten.select do |availability|
        availability.new_record? || availability.changed?
      end
      Availability.import new_availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on] }
    end

    if new_prices.present?
      new_prices.each { |price| price.availability_id = price.availability.id }
      Price.import new_prices, batch_size: 150, on_duplicate_key_update: { columns: %i[amount children infants adults minimum_stay] }
      new_prices.each(&:reindex)
    end

    if new_cleaning_costs.present?
      cleaning_costs.each { |cleaning_cost| cleaning_cost.availability_id = cleaning_cost.availability.id }
      CleaningCost.import new_cleaning_costs, batch: 150, on_duplicate_key_update: { columns: %i[fixed_price name] }
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
      room_rate_ids = availabilities.map(&:room_type_id)
      availability_index = new_availabilities.index do |new_availability|
        dates.include?(new_availability.available_on) &&
          room_rate_ids.include?(new_availability.room_type_id)
      end

      availability_index.present?
    end
end
