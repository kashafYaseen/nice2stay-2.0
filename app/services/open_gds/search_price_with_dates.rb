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
      return [] if params[:children] == '0' && params[:infants] == '0'

      if params[:children] != '0' && params[:infants] != '0'
        children_rate = room_rate.child_rates_children.order(rate: :desc).first
        infants_rate = room_rate.child_rates_infants.order(rate: :desc).first
        price = room_rate.rate_plan_ps? ? price_list.sum : price_list.sum / total_adults
        children_rates = []
        children_rates = [price] if can_charge_adult_rate_to_children?

        child_rate = children_rate&.rate
        infant_rate = infants_rate&.rate
        num_of_stays = params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?
        if infants_rate&.open_gds_category.to_i > children_rate&.open_gds_category.to_i
          num_of_children_with_extrabeds = extra_beds_used_by_children(params[:children].to_i)
          children_rates += [(child_rate || room_rate.extra_bed_rate || price) * num_of_stays] * num_of_children_with_extrabeds
          @children_without_extrabeds = params[:children].to_i - num_of_children_with_extrabeds
          # num_of_children = num_of_children_with_extrabeds.zero? ? params[:children].to_i : params[:children].to_i +
          children_rates += [(infant_rate || room_rate.extra_bed_rate || price) * num_of_stays] * extra_beds_used_by_children(num_of_children_with_extrabeds + params[:infants].to_i)
          @infants_without_extrabeds = params[:infants].to_i - extra_beds_used_by_children(num_of_children_with_extrabeds + params[:infants].to_i)
        else
          num_of_infants_with_extrabeds = extra_beds_used_by_children(params[:infants].to_i)
          @infants_without_extrabeds = params[:infants].to_i - num_of_infants_with_extrabeds
          children_rates += [(infant_rate || room_rate.extra_bed_rate || price) * num_of_stays] * num_of_infants_with_extrabeds
          children_rates += [(child_rate || room_rate.extra_bed_rate || price) * num_of_stays] * extra_beds_used_by_children(params[:children].to_i + num_of_infants_with_extrabeds)
          @children_without_extrabeds = params[:children].to_i - extra_beds_used_by_children(params[:children].to_i + num_of_infants_with_extrabeds)
        end

        if @children_without_extrabeds.positive?
          can_charge_adult_rate_to_children? && @children_without_extrabeds -= 1
          children_rates += [(child_rate || price) * num_of_stays] * @children_without_extrabeds
        end

        unless @infants_without_extrabeds.positive?
          can_charge_adult_rate_to_children? && @infants_without_extrabeds -= 1
          children_rates += [(child_rate || price) * num_of_stays] * @infants_without_extrabeds
        end

        # @child_rate *= params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?
        # num_of_children_without_extra_beds = total_children - extra_beds_used_by_children(params[:children].to_i + params[:infants].to_i)
        # num_of_children -= 1 if total_adults == 1 && (!room_rate.rate_plan_ps? && !room_rate.rate_plan_papn?)
        # @child_rate
      end

      # if params[:children] != '0' && params[:infants] != '0'
      #   children_rate = room_rate.child_rates_children.order(rate: :desc).first
      #   infants_rate = room_rate.child_rates_infants.order(rate: :desc).first
      #   if children_rate.nil? && infants_rate.nil?
      #     @total_children = params[:children].to_i + params[:infants].to_i
      #   else
      #     price = price_list.sum if total_adults == 1 && (!room_rate.rate_plan_ps? && !room_rate.rate_plan_papn?)
      #     infant_rate = infants_rate&.rate || room_rate.extra_bed_rate || price
      #     # infant_rate = infant_rate.zero? ? price_list.sum : infant_rate
      #     child_rate = children_rate&.rate || room_rate.extra_bed_rate || price
      #     # child_rate = child_rate.zero? ? price_list.sum : child_rate
      #     if infants_rate.open_gds_category.to_i > children_rate.open_gds_category.to_i
      #       child_rate *= extra_beds_used_by_children(params[:children].to_i)
      #       num_of_children = params[:children].to_i if child_rate.zero?
      #       infant_rate *= extra_beds_used_by_children(num_of_children.to_i + params[:infants].to_i)
      #     else
      #       infant_rate *= extra_beds_used_by_children(params[:infants].to_i)
      #       num_of_infants = params[:infants].to_i if infant_rate.zero?
      #       child_rate *= extra_beds_used_by_children(params[:children].to_i + num_of_infants.to_i)
      #     end
      #
      #     price = price_list.sum if total_adults == 1 && (!room_rate.rate_plan_ps? && !room_rate.rate_plan_papn?)
      #     num_of_stays = params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?
      #     return [infant_rate + child_rate + price.to_f] * num_of_stays.to_i
      #   end
      # elsif params[:children] != '0' && params[:infants] == '0'
      #   @child_rate = room_rate.child_rates_children.order(rate: :desc).first&.rate
      #   @total_children = params[:children].to_i
      # else
      #   @child_rate = room_rate.child_rates_infants.order(rate: :desc).first&.rate
      #   @total_children = params[:infants].to_i
      # end
      #
      # price = room_rate.rate_plan_ps? ? price_list.sum : price_list.sum / total_adults
      # # @child_rate += price if total_adults == 1 && !room_rzate.rate_plan_ps?
      # children_with_extra_beds = extra_beds_used_by_children(@total_children)
      # if children_with_extra_beds.positive?
      #   @child_rate ||= room_rate.extra_bed_rate || price
      #   # @child_rate += price if total_adults == 1 && !room_rzate.rate_plan_ps?
      #   @children = children_with_extra_beds
      #   # [@child_rate * extra_beds]
      # else
      #   # @child_rate ||= price
      #   @child_rate = price
      #   @children = 0 if room_rate.rate_plan_ps?
      #   # [@child_rate * (room_rate.rate_plan_ps? ? extra_beds : @total_children)]
      # end
      #
      # byebug
      # num_of_stays = params[:minimum_stay].to_i if room_rate.rate_plan_pppn? || room_rate.rate_plan_pppd? || room_rate.rate_plan_papn?
      # # if room_rate.rate_plan_papn?
      # #   [@child_rate * total_extra_beds_used] * num_of_stays.to_i
      # # else
      # @child_rate = [@child_rate * @children] * num_of_stays.to_i
      # # if @total_children - children_with_extra_beds.positive?
      # # end
      # @child_rate += [price] if total_adults == 1 && !room_rate.rate_plan_ps?
      #
      # # [@child_rate * @total_children] * num_of_stays.to_i
      # # end
      # @child_rate
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
      children_with_extra_beds = (adults_without_extra_beds - num_of_children).abs
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
      room_rate.rate_plan_pppd? && total_adults == 1
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end
end
