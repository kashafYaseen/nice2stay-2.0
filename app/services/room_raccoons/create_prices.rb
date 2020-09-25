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
          room_id,
          rate_plan_code,
          start_date,
          end_date,
          rates = parse_data(rate_amount_message)

          create_prices_and_discounts(room_id, rate_plan_code, start_date, end_date, rates)
        end
      else
        room_id,
        rate_plan_code,
        start_date,
        end_date,
        rates = parse_data(@body['OTA_HotelRateAmountNotifRQ']['RateAmountMessages']['RateAmountMessage'])

        create_prices_and_discounts(room_id, rate_plan_code, start_date, end_date, rates)
      end

      true
    rescue
      false
    end
  end

  private
    def parse_data(data)
      room_id = data['StatusApplicationControl']['InvTypeCode']
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

      return room_id, rate_plan_code, start_date, end_date, rates.sort_by { |rate| rate[:guests] }
    end

    def create_prices_and_discounts(room_id, rate_plan_code, start_date, end_date, rates)
      room = hotel.lodging_children.find(room_id)

      if rates.size > 1
        discount = room.discounts.find_or_initialize_by(rr_rate_plan_code: rate_plan_code)
        rate = rates.first
        discount.value = rate[:amount]
        discount.guests = rate[:guests]
        discount.discount_type = "amount"
        discount.start_date = start_date
        discount.end_date = end_date
        discount.save
      end

      availabilities = room.availabilities.for_range(start_date, end_date)
      availabilities.each do |availability|
        price = availability.prices.find_or_initialize_by(rr_rate_plan_code: rate_plan_code)
        rate = rates.last
        price.amount = rate[:amount]
        rate[:age_qualifying_code] == "10" ? price.adults = [rate[:guests]] : price.children = [rate[:guests]]
        price.save
      end
    end
end
