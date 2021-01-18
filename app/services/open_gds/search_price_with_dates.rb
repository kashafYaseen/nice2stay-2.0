class OpenGds::SearchPriceWithDates
  attr_reader :params,
              :room_rate

  def self.call(params, room_rate)
    new(params, room_rate).call
  end

  def initialize(params, room_rate)
    @params = params
    @room_rate = room_rate
  end

  def call
    search_price_with_defaults
  end

  private
    def search_price_with_defaults
      price_list = SearchPrices.call(params).uniq(&:available_on).pluck(:amount)
      byebug
      price = room_rate.default_rate
      price_list += [price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end
end
