class RoomRaccoons::CreatePrices
  attr_reader :body
  attr_reader :hotel

  def initialize(body, hotel_id)
    @body = body
    @hotel = Lodging.find_by(id: hotel_id)
  end

  def self.call(body, hotel_id)
    self.new(body, hotel_id).call
  end

  def call
    begin
      parsed_data = []
      if @body['rateamountmessages']['rateamountmessage'].kind_of?(Array)
        @body['rateamountmessages']['rateamountmessage'].each do |rate_amount_message|
          parsed_data << parse_data(rate_amount_message)
        end
      else
        parsed_data << parse_data(@body['rateamountmessages']['rateamountmessage'])
      end

      dates = parsed_data.map { |data| (data[:start_date]..data[:end_date]).map(&:to_s) }.flatten.uniq.sort
      rooms = hotel.room_types.joins(availabilities: :rate_plan).where(room_types: { code: parsed_data.map {|data| data[:room_type_code] }.uniq }, rate_plans: { code: parsed_data.map {|data| data[:rate_plan_code] }.uniq }).select("availabilities.available_on as available_on")
      rooms = rooms.map { |room| room if dates.include?(room.available_on.to_s) }.delete_if { |room| room.blank? }
      return false if rooms.size == 0
      RrCreatePricesJob.perform_later hotel, parsed_data
      return true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Prices============>: #{ e }"
      return false
    end
  end

  private
    def parse_data(data)
      room_type_code = data['statusapplicationcontrol']['invtypecode']
      rate_plan_code = data['statusapplicationcontrol']['rateplancode']
      start_date = data['statusapplicationcontrol']['start']
      end_date = data['statusapplicationcontrol']['end']

      base_by_guest_amts = data['rates']['rate']['basebyguestamts']['basebyguestamt']
      rates = []
      if base_by_guest_amts.kind_of?(Array)
        base_by_guest_amts.each do |base_by_guest_amt|
          rates << guests_base_amount(base_by_guest_amt)
        end
      else
        rates << guests_base_amount(base_by_guest_amts)
      end

      additional_guest_amounts = data['rates']['rate']['additionalguestamounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = data['rates']['rate']['additionalguestamounts']['additionalguestamount']

        if additional_guest_amounts.kind_of?(Array)
          additional_guest_amounts.each do |additional_guest_amount|
            additional_amounts << guests_additional_amount(additional_guest_amount)
          end
        else
          additional_amounts << guests_additional_amount(additional_guest_amounts)
        end
      end

      return {
        room_type_code: room_type_code&.upcase,
        rate_plan_code: rate_plan_code&.upcase,
        start_date: start_date,
        end_date: end_date,
        rates: rates,
        additional_amounts: additional_amounts
      }
    end

    def guests_base_amount params
      {
        age_qualifying_code: params['agequalifyingcode'],
        guests: params['numberofguests'].present? ? params['numberofguests'] : "999",
        amount: params['amountaftertax']
      }
    end

    def guests_additional_amount params
      {
        age_qualifying_code: params['agequalifyingcode'],
        amount: params['amount']
      }
    end
end
