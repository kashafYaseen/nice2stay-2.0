class RoomRaccoons::CreatePrices
  attr_reader :body
  attr_reader :hotel

  def initialize(body, hotel)
    @body = body
    @hotel = hotel
  end

  def self.call(body, hotel)
    self.new(body, hotel).call
  end

  def call
    begin
      if @body['OTA_HotelRateAmountNotifRQ']['RateAmountMessages']['RateAmountMessage'].kind_of?(Array)
        @body['OTA_HotelRateAmountNotifRQ']['RateAmountMessages']['RateAmountMessage'].each do |rate_amount_message|
          room_type_code,
          rate_plan_code,
          start_date,
          end_date,
          rates,
          additional_amounts = parse_data(rate_amount_message)

          create_prices_and_discounts(room_type_code, rate_plan_code, start_date, end_date, rates, additional_amounts)
        end
      else
        room_type_code,
        rate_plan_code,
        start_date,
        end_date,
        rates,
        additional_amounts = parse_data(@body['OTA_HotelRateAmountNotifRQ']['RateAmountMessages']['RateAmountMessage'])

        create_prices_and_discounts(room_type_code, rate_plan_code, start_date, end_date, rates, additional_amounts)
      end

      true
    rescue
      false
    end
  end

  private
    def parse_data(data)
      room_type_code = data['StatusApplicationControl']['InvTypeCode']
      rate_plan_code = data['StatusApplicationControl']['RatePlanCode']
      start_date = data['StatusApplicationControl']['Start'].to_date
      end_date = data['StatusApplicationControl']['End'].to_date

      base_by_guest_amts = data['Rates']['Rate']['BaseByGuestAmts']['BaseByGuestAmt']
      rates = []
      if base_by_guest_amts.kind_of?(Array)
        base_by_guest_amts.each do |base_by_guest_amt|
          rates << {
            age_qualifying_code: base_by_guest_amt['AgeQualifyingCode'],
            guests: base_by_guest_amt['NumberOfGuests'],
            amount: base_by_guest_amt['AmountAfterTax']
          }
        end
      else
        rates << {
          age_qualifying_code: base_by_guest_amt['AgeQualifyingCode'],
          guests: base_by_guest_amt['NumberOfGuests'],
          amount: base_by_guest_amt['AmountAfterTax']
        }
      end

      additional_guest_amounts = data['Rates']['Rate']['AdditionalGuestAmounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = data['Rates']['Rate']['AdditionalGuestAmounts']['AdditionalGuestAmount']
        additional_guest_amounts.each do |additional_guest_amount|
          additional_amounts << {
            age_qualifying_code: additional_guest_amount['AgeQualifyingCode'],
            amount: additional_guest_amount['Amount']
          }
        end
      end

      return room_type_code, rate_plan_code, start_date, end_date, rates, additional_amounts
    end

    def create_prices_and_discounts(room_type_code, rate_plan_code, start_date, end_date, rates, additional_amounts)
      rooms = hotel.room_types.find_by(code: room_type_code).child_lodgings

      rooms.each do |room|
        availabilities = room.availabilities.for_range(start_date, end_date)

        availabilities.each do |availability|
          rates.each do |rate|
            price = availability.prices.new(amount: rate[:amount])
            if rate[:age_qualifying_code].present?
              rate[:age_qualifying_code] == "10" ? price.adults = [rate[:guests]] : price.children = [rate[:guests]]
            else
              price.adults = [rate[:guests]]
            end
            price.save
          end
        end

        if additional_amounts.present?
          additional_amounts.each do |additional_amount|
            room.cleaning_costs.create(
              fixed_price: additional_amount[:amount],
              name: additional_amount[:age_qualifying_code] == "10" ? "Adults" : "Children"
            )
          end
        end
      end
    end
end
