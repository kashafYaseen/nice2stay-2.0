class RrCreatePricesJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(hotel, parsed_data)
    hotel_room_types = hotel.room_types.includes(availabilities: [:rate_plan, :prices, :cleaning_costs]).where(room_types: { code: parsed_data.map {|data| data[:room_type_code] }.uniq })
    new_prices = []
    new_cleaning_costs = []

    parsed_data.each do |data|
      dates = (data[:start_date].to_date..data[:end_date].to_date).map(&:to_s)
      @room_types = hotel_room_types.map { |room_type| room_type if room_type.code == data[:room_type_code] }.delete_if {|room_type| room_type.blank? }

      @room_types.each do |room_type|
        availabilities = room_type.availabilities.map { |availability| availability if dates.include?(availability.available_on.to_s) && availability.rate_plan_code == data[:rate_plan_code] }.delete_if { |availability| availability.blank? }
        availabilities.each do |availability|
          prices = availability.prices
          data[:rates].each do |rate|
            if rate[:age_qualifying_code].present?
              @price_index = prices.find_index { |price|
                (rate[:age_qualifying_code] == "7" && price.infants == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == "8" && price.children == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == "10" && price.adults == [rate[:guests]])
              }
            else
              @price_index = prices.find_index { |price| !(price.children.present? || price.adults.present? || price.infants.present?) }
            end

            if @price_index.present?
              @price = prices[@price_index]
              @price.amount = rate[:amount]
            else
              @price = availability.prices.new(amount: rate[:amount], created_at: DateTime.now, updated_at: DateTime.now)
            end

            if rate[:age_qualifying_code] == "7"
              @price.infants = [rate[:guests]]
            elsif rate[:age_qualifying_code] == "8"
              @price.children = [rate[:guests]]
            else
              @price.adults = [rate[:guests]]
            end

            @price.minimum_stay = availability.rr_minimum_stay
            new_prices << @price if @price.new_record? || @price.changed?
          end

          if data[:additional_amounts].present?
            cleaning_costs = availability.cleaning_costs

            data[:additional_amounts].each do |additional_amount|
              cleaning_cost_index = cleaning_costs.find_index { |cleaning_cost|
                (additional_amount[:age_qualifying_code] == "7" && cleaning_cost.name == "Infants") ||
                (additional_amount[:age_qualifying_code] == "8" && cleaning_cost.name == "Children") ||
                (additional_amount[:age_qualifying_code] == "10" && cleaning_cost.name == "Adults")
              }

              if cleaning_cost_index.present?
                @cleaning_cost = cleaning_costs[cleaning_cost_index]
                @cleaning_cost.fixed_price = additional_amount[:amount]
              else
                @cleaning_cost = cleaning_costs.new(fixed_price: additional_amount[:amount], created_at: DateTime.now, updated_at: DateTime.now)
              end

              if additional_amount[:age_qualifying_code] == "7"
                @cleaning_cost.name = "Infants"
              elsif additional_amount[:age_qualifying_code] == "8"
                @cleaning_cost.name = "Children"
              else
                @cleaning_cost.name = "Adults"
              end

              new_cleaning_costs << @cleaning_cost if @cleaning_cost.new_record? || @cleaning_cost.changed?
            end
          end
        end
      end
    end

    Price.import new_prices, batch_size: 150, on_duplicate_key_update: { columns: [:amount, :children, :infants, :adults, :minimum_stay] } if new_prices.present?
    CleaningCost.import new_cleaning_costs, batch: 150, on_duplicate_key_update: { columns: [:fixed_price, :name] } if new_cleaning_costs.present?
  end
end