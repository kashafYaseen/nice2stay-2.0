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
      if  params[:adults].to_i == 1 && params[:children].to_i.zero? && params[:infants].to_i.zero? && room_rate.single_supplement?
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements] + [room_rate.default_single_rate]
      elsif  params[:adults].to_i == 1 && params[:children].to_i.zero? && params[:infants].to_i.zero? && room_rate.single_rate?
        @adults_rates = ([(room_rate.default_single_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      else
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      end

      return @adults_rates if room_rate.extra_beds_for_children_only

      adults_with_extra_beds = extra_beds_used_by_adults[0]
      @adults_rates += [room_rate.extra_bed_rate.to_f * adults_with_extra_beds]
    end

    def calculate_adult_rates prices
      if params[:adults].to_i == 1 && params[:children].to_i.zero? && params[:infants].to_i.zero? && room_rate.single_rate?
        @price_list = prices.map { |price| { amount: price.open_gds_single_rate, date: price.available_on } }
      else
        @price_list = prices.map { |price| { amount: price.amount, date: price.available_on } }
        @default_single_rate = room_rate.default_single_rate if  params[:adults].to_i == 1 && params[:children].to_i.zero? && params[:infants].to_i.zero? && room_rate.single_supplement?
      end
      if room_rate.rate_plan_pp?
        @adults_rates = @price_list.map { |price| ((price[:amount] / params[:minimum_stay]) + get_daily_supplements(price[:date])) } * total_adults + [@default_single_rate.to_i]
      else
        # adults = total_adults unless room_rate.rate_plan_papn?
        @adults_rates = @price_list.map { |price| price[:amount] + get_daily_supplements(price[:date]) } + [@default_single_rate.to_i * params[:minimum_stay]]
        @adults_rates *= total_adults unless room_rate.rate_plan_papn?
      end

      return @adults_rates if room_rate.extra_beds_for_children_only

      adults_with_extra_beds = extra_beds_used_by_adults[0]
      return @adults_rates if adults_with_extra_beds.zero?

      extra_bed_rate = room_rate.extra_bed_rate.present? ? room_rate.extra_bed_rate : @adults_rates.sum / total_adults
      extra_bed_rate *= params[:minimum_stay] if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?
      @adults_rates += [extra_bed_rate * adults_with_extra_beds]
    end

    def calculate_child_rates price_list
      return [] if params[:children].to_i.zero? && params[:infants].to_i.zero?

      children_rate = room_rate.child_rates_children.order(rate: :desc).first if params[:children].to_i.positive?
      infants_rate = room_rate.child_rates_infants.order(rate: :desc).first if params[:infants].to_i.positive?
      price = room_rate.rate_plan_ps? ? price_list.sum : price_list.sum / total_adults
      children_rates = []
      children_rates = [price] if can_charge_adult_rate_to_children?

      child_rate = children_rate&.rate
      infant_rate = infants_rate&.rate
      num_of_stays = params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?

      if params[:children].to_i.positive? && params[:infants].to_i.positive?
        if infants_rate&.open_gds_category.to_i > children_rate&.open_gds_category.to_i
          @num_of_children_with_extrabeds = extra_beds_used_by_children(params[:children].to_i)
          @children_without_extrabeds = params[:children].to_i - @num_of_children_with_extrabeds
          @occupant_is_child = @children_without_extrabeds.positive?
          @infants_without_extrabeds = params[:infants].to_i - extra_beds_used_by_children(@num_of_children_with_extrabeds + params[:infants].to_i)
          @amounts = [child_rate || room_rate.extra_bed_rate]
          @amounts += [infant_rate || room_rate.extra_bed_rate]
          @children = params[:infants].to_i
        else
          @num_of_children_with_extrabeds = extra_beds_used_by_children(params[:infants].to_i)
          @infants_without_extrabeds = params[:infants].to_i - @num_of_children_with_extrabeds
          @occupant_is_infant = @infants_without_extrabeds.positive?
          @children_without_extrabeds = params[:children].to_i - extra_beds_used_by_children(params[:children].to_i + @num_of_children_with_extrabeds)
          @amounts = [infant_rate || room_rate.extra_bed_rate]
          @amounts += [child_rate || room_rate.extra_bed_rate]
          @children = @children = params[:children].to_i
        end
      elsif params[:children].to_i.positive? && params[:infants].to_i.zero?
        @num_of_children_with_extrabeds = extra_beds_used_by_children(params[:children].to_i)
        @children_without_extrabeds = params[:children].to_i - @num_of_children_with_extrabeds
        @occupant_is_child = @children_without_extrabeds.positive?
        @amounts = [child_rate || room_rate.extra_bed_rate]
      else
        @num_of_children_with_extrabeds = extra_beds_used_by_children(params[:infants].to_i)
        @infants_without_extrabeds = params[:infants].to_i - @num_of_children_with_extrabeds
        @occupant_is_infant = @infants_without_extrabeds.positive?
        @amounts = [infant_rate || room_rate.extra_bed_rate]
      end

      children_rates += [(@amounts[0] || price / num_of_stays) * num_of_stays] * @num_of_children_with_extrabeds
      can_charge_adult_rate_to_children? && @occupant_is_child && @children_without_extrabeds -= 1
      can_charge_adult_rate_to_children? && @occupant_is_infant && @infants_without_extrabeds -= 1

      if @children_without_extrabeds&.positive?
        children_rates += [(child_rate || room_rate.extra_bed_rate || price / num_of_stays) * num_of_stays] * @children_without_extrabeds
      end

      if @infants_without_extrabeds&.positive?
        children_rates += [(infant_rate || room_rate.extra_bed_rate || price / num_of_stays) * num_of_stays] * @infants_without_extrabeds
      end
      return children_rates unless params[:children].to_i.positive? && params[:infants].to_i.positive?

      children_rates += [(@amounts[1] || price / num_of_stays) * num_of_stays] * extra_beds_used_by_children(@num_of_children_with_extrabeds + @children)
      children_rates
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
      return 0 if num_of_children.zero?

      adults_without_extra_beds = extra_beds_used_by_adults[-1]
      children_with_extra_beds = adults_without_extra_beds - num_of_children
      children_with_extra_beds = children_with_extra_beds.negative? ? children_with_extra_beds.abs : 0
      children_with_extra_beds -= adults_without_extra_beds.abs if adults_without_extra_beds.negative?
      children_with_extra_beds
    end

    # def total_extra_beds_used
    #   (((params[:max_adults].to_i + room_rate.extra_beds) - (params[:adults].to_i + params[:children].to_i)) - room_rate.extra_beds).abs
    # end

    def total_adults
      return params[:adults].to_i if params[:adults].to_i <= params[:max_adults].to_i

      params[:max_adults].to_i
    end

    def total_children
      params[:children].to_i + params[:infants].to_i
    end

    def can_charge_adult_rate_to_children?
      (room_rate.rate_plan_pppd? || room_rate.rate_plan_pppn?) && total_adults == 1
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end
end
