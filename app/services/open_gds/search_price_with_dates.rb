module OpenGds::SearchPriceWithDates
  def calculate_adult_rates prices
    return [] if prices.blank?

    if params[:adults].to_i == 1 && params[:children].to_i.zero? && room_rate.single_rate?
      @price_list = prices.map { |price| { amount: price.open_gds_single_rate, date: price.available_on } }
    else
      @price_list = prices.map { |price| { amount: price.amount, date: price.available_on } }
      @default_single_rate = room_rate.default_single_rate if  params[:adults].to_i == 1 && params[:children].to_i.zero? && room_rate.single_supplement?
    end

    if room_rate.rate_plan_ps? && @price_list.present?
      first_day_price = @price_list.first[:amount] / total_stay # add first day amount for all days in stay
      @adults_rates = @price_list.map { |price| (first_day_price + get_daily_supplements(price[:date])) } + [@default_single_rate.to_i]
    elsif room_rate.rate_plan_pp?
      @adults_rates = @price_list.map { |price| ((price[:amount] / total_stay) + get_daily_supplements(price[:date])) } * total_adults + [@default_single_rate.to_i]
    else
      @adults_rates = @price_list.map { |price| price[:amount] + get_daily_supplements(price[:date]) } + [@default_single_rate.to_i * total_stay]
      @adults_rates *= total_adults unless room_rate.rate_plan_papn? || room_rate.rate_plan_papd?
    end

    return @adults_rates if room_rate.extra_beds_for_children_only

    adults_with_extra_beds = extra_beds_used_by_adults[0]
    return @adults_rates if adults_with_extra_beds.zero?

    if rate_type_involve_person?
      extra_bed_rate = room_rate.extra_bed_rate || @adults_rates.sum / total_adults
      extra_bed_rate *= total_stay if room_rate.extra_bed_rate.present? && !room_rate.rate_plan_pp?
    else
      extra_bed_rate = room_rate.extra_bed_rate.to_f
      extra_bed_rate *= total_stay if room_rate.rate_plan_papd? || room_rate.rate_plan_papn?
    end

    @adults_rates += [extra_bed_rate * adults_with_extra_beds]
  end

  def calculate_children_rates price_list
    return [] if params[:children].to_i.zero? || price_list.blank?

    children_rate = room_rate.child_rates.order(rate: :desc).first
    price = rate_type_involve_person? ? price_list.sum / total_adults : price_list.sum
    children_rates = []
    children_rates = [price] if can_charge_adult_rate_to_children?
    # child_rate = children_rate&.rate
    num_of_stays = total_stay if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn? || room_rate.rate_plan_papd?
    num_of_children_with_extrabeds = extra_beds_used_by_children(params[:children].to_i)
    children_without_extrabeds = params[:children].to_i - num_of_children_with_extrabeds
    occupant_is_child = children_without_extrabeds.positive?
    children_rates += children_rates_by_rate_type(children_rate&.rate || room_rate.extra_bed_rate, price, num_of_stays, num_of_children_with_extrabeds)
    children_without_extrabeds -= 1 if can_charge_adult_rate_to_children? && children_without_extrabeds.positive?
    children_rates += children_rates_by_rate_type(children_rate&.rate, price, num_of_stays, children_without_extrabeds) if children_without_extrabeds.positive? && rate_type_involve_person?
    children_rates
  end

  def check_out
    return unless params[:check_out].present?
    room_rate.rate_plan_pppd? || room_rate.rate_plan_papd? ? params[:check_out].to_date.next_day.to_s : params[:check_out]
  end

  private
    def get_daily_supplements date
      return 0 unless room_rate.open_gds_daily_supplements.present?
      room_rate.open_gds_daily_supplements[date.strftime('%a')].to_f
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

    def total_adults
      return params[:adults].to_i if params[:adults].to_i <= params[:max_adults].to_i

      params[:max_adults].to_i
    end

    def can_charge_adult_rate_to_children?
      rate_type_involve_person? && total_adults == 1
    end

    def children_rates_by_rate_type(amount, single_adult_amount, num_of_stays, num_of_children)
      return [amount || single_adult_amount] * num_of_children if room_rate.rate_plan_pp? || room_rate.rate_plan_ps?
      [(amount || single_adult_amount / num_of_stays) * num_of_stays] * num_of_children
    end

    def total_stay
      return params[:minimum_stay].to_i + 1 if room_rate.rate_plan_pppd? || room_rate.rate_plan_papd?
      params[:minimum_stay].to_i
    end

    def rate_type_involve_person?
      room_rate.rate_plan_pp? || room_rate.rate_plan_pppd? || room_rate.rate_plan.pppn?
    end
end
