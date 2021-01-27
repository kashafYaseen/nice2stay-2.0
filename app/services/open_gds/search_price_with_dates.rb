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
      if room_rate.rate_plan_ps?
        @price_list = calculate_adult_rates_with_defaults
      else
        @prices = SearchPrices.call(params.merge(children: 0)).uniq(&:available_on)
        @price_list = calculate_adult_rates(@prices)
      end
      @price_list += calculate_child_rates(@price_list)
      @price_list += [room_rate.open_gds_res_fee]
      reservation = build_reservation params
      { rates: @price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def calculate_adult_rates_with_defaults
      if params[:adults] == '1' && params[:children] == '0' && params[:infants] == '0' && room_rate.single_supplement?
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements] + [room_rate.default_single_rate]
      elsif params[:adults] == '1' && params[:children] == '0' && params[:infants] == '0' && room_rate.single_rate?
        @adults_rates = ([(room_rate.default_single_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      else
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      end

      return @adults_rates if room_rate.extra_beds_for_children_only

      adults_with_extra_beds = extra_beds_used_by_adults[0]
      @adults_rates += [room_rate.extra_bed_rate.to_f * adults_with_extra_beds]
    end

    def calculate_adult_rates prices
      if params[:adults] == '1' && params[:children] == '0' && room_rate.single_rate?
        @price_list = prices.map { |price| { amount: price.open_gds_single_rate, date: price.available_on } }
      else
        @price_list = prices.map { |price| { amount: price.amount, date: price.available_on } }
        @default_single_rate = room_rate.default_single_rate if params[:adults] == '1' && params[:children] == '0' && room_rate.single_supplement?
      end
      if room_rate.rate_plan_pp?
        @adults_rates = @price_list.map { |price| ((price[:amount] / params[:minimum_stay]) + get_daily_supplements(price[:date])) } * total_adults + [@default_single_rate.to_i]
      else
        @adults_rates = @price_list.map { |price| price[:amount] + get_daily_supplements(price[:date]) } * total_adults + [@default_single_rate.to_i * params[:minimum_stay]]
      end

      return @adults_rates if room_rate.extra_beds_for_children_only

      adults_with_extra_beds = extra_beds_used_by_adults[0]
      return @adults_rates if adults_with_extra_beds.zero?

      extra_bed_rate = room_rate.extra_bed_rate.present? ? room_rate.extra_bed_rate : @adults_rates.sum / total_adults
      extra_bed_rate *= params[:minimum_stay] if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd?
      @adults_rates += [extra_bed_rate * adults_with_extra_beds]
    end

    def calculate_child_rates price_list
      return [] if params[:children] == '0' && params[:infants] == '0'

      if params[:children] != '0' && params[:infants] != '0'
        children_rate = room_rate.child_rates_children.order(rate: :desc).first
        infants_rate = room_rate.child_rates_infants.order(rate: :desc).first
        if children_rate.nil? && infants_rate.nil?
          @total_children = params[:children].to_i + params[:infants].to_i
        else
          infant_rate = infants_rate&.rate || room_rate.extra_bed_rate
          infant_rate = infant_rate.zero? ? price_list.sum : infant_rate
          child_rate = children_rate&.rate || room_rate.extra_bed_rate
          child_rate = child_rate.zero? ? price_list.sum : child_rate
          if infants_rate.open_gds_category.to_i > children_rate.open_gds_category.to_i
            child_rate *= extra_beds_used_by_children(params[:children].to_i)
            num_of_children = params[:infants].to_i if child_rate.zero?
            infant_rate *= extra_beds_used_by_children(num_of_children.to_i + params[:infants].to_i)
          else
            infant_rate *= extra_beds_used_by_children(params[:infants].to_i)
            num_of_infants = params[:infants].to_i if infant_rate.zero?
            child_rate *= extra_beds_used_by_children(params[:children].to_i + num_of_infants.to_i)
          end

          price = price_list.sum if total_adults == 1 && !room_rate.rate_plan_ps?
          return [infant_rate + child_rate + price.to_f]
        end
      elsif params[:children] != '0' && params[:infants] == '0'
        @child_rate = room_rate.child_rates_children.order(rate: :desc).first&.rate
        @total_children = params[:children].to_i
      else
        @child_rate = room_rate.child_rates_infants.order(rate: :desc).first&.rate
        @total_children = params[:infants].to_i
      end

      price = room_rate.rate_plan_ps? ? price_list.sum : price_list.sum / total_adults
      children_with_extra_beds = extra_beds_used_by_children(@total_children)
      if children_with_extra_beds.positive?
        @child_rate ||= room_rate.extra_bed_rate || price
        @child_rate += price if total_adults == 1 && !room_rate.rate_plan_ps?
        @total_children = children_with_extra_beds
        # [@child_rate * extra_beds]
      else
        # @child_rate ||= price
        @child_rate = price
        @total_children = 0 if room_rate.rate_plan_ps?
        # [@child_rate * (room_rate.rate_plan_ps? ? extra_beds : @total_children)]
      end

      num_of_stays = params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd?
      [@child_rate * @total_children * num_of_stays.to_i]
    end

    def get_daily_supplements date = nil
      return 0 unless room_rate.open_gds_daily_supplements.present?

      daily_supplements = room_rate.open_gds_daily_supplements
      return daily_supplements[date.strftime('%a')].to_f if date.present?

      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (check_in.to_date..check_out.to_date.prev_day).map(&:to_date).inject(0) do |sum, date|
        sum + daily_supplements[date.strftime('%a')].to_f
      end
    end

    def extra_beds_used_by_adults
      adults_without_extra_beds = params[:max_adults].to_i - params[:adults].to_i
      adults_with_extra_beds = adults_without_extra_beds.positive? ? 0 : adults_without_extra_beds.abs
      [adults_with_extra_beds, adults_without_extra_beds]
    end

    def extra_beds_used_by_children num_of_children
      adults_without_extra_beds = extra_beds_used_by_adults[-1]
      total_extra_beds = (adults_without_extra_beds - num_of_children).abs
      total_extra_beds -= adults_without_extra_beds.abs if adults_without_extra_beds.negative?
      total_extra_beds
    end

    def total_adults
      return params[:adults].to_i if params[:adults].to_i <= params[:max_adults].to_i

      params[:max_adults].to_i
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end
end
