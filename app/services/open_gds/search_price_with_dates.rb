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
      # prices = SearchPrices.call(params.merge(children: 0)).uniq(&:available_on)
      # price_list = prices.pluck(:amount)
      if room_rate.rate_plan_ps?
        @price_list = adult_rate_by_single_rate_type
        @price_list += calculate_child_rates(@price_list)
        @price_list += [room_rate.open_gds_res_fee]
      end
      # if room_rate.single_supplement? && params[:adult] == '1' && params[:children] == '0'
      #   @single_rate = prices.pluck(:open_gds_single_rate).sum
      # elsif room_rate.single_rate? && params[:adult] == '1' && params[:children] == '0'
      #   price_list = prices.pluck(:open_gds_single_rate)
      # end
      #
      # price = room_type.extra_night_rate.present? ? room_type.extra_night_rate : room_rate.default_rate
      # price_list += [price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      # price_list += [@single_rate] if @single_rate.present?
      # price_list += get_daily_supplements
      reservation = build_reservation params
      { rates: @price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end

    def get_daily_supplements
      return 0 unless room_rate.open_gds_daily_supplements.present?

      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      daily_supplements = room_rate.open_gds_daily_supplements
      (check_in.to_date..check_out.to_date - 1.day).map(&:to_date).inject(0) do |sum, date|
        sum + daily_supplements[date.strftime('%a')].to_f
      end
    end

    def calculate_child_rates price_list
      return if params[:children] == '0' && params[:infants] == '0'

      if params[:children] != '0' && params[:infants] != '0'
        children_rate = room_rate.child_rates_children.order(rate: :desc).first
        infants_rate = room_rate.child_rates_children.order(rate: :desc).first
        if children_rate.nil? && infants_rate.nil?
          child_rate = room_rate.extra_bed_rate.zero? ? price_list.sum : child_rate
          return [child_rate * extra_beds_used_by_children(params[:children].to_i + params[:infants].to_i)]
        end

        infant_rate = infant_rates&.rate || room_rate.extra_bed_rate
        infants_rate = infant_rate.zero? ? price_list.sum : infant_rate
        child_rate = children_rate&.rate || room_rate.extra_bed_rate
        child_rate = children_rate.zero? ? price_list.sum : child_rate
        if infants_rate.category.to_i > children_rate.category.to_i
          infant_rate *= extra_beds_used_by_children(params[:infants].to_i)
          child_rate *= extra_beds_used_by_children(params[:children].to_i + params[:infants].to_i)
        else
          child_rate *= extra_beds_used_by_children(params[:children].to_i)
          infant_rate *= extra_beds_used_by_children(params[:children].to_i + params[:infants].to_i)
        end

        [infant_rate + child_rate]
      elsif params[:children] != '0' && params[:infants] == '0'
        @child_rate = room_rate.child_rates_children.order(rate: :desc).first&.rate || room_rate.extra_bed_rate
        child_rate = child_rate.zero? ? price_list.sum : child_rate
        [child_rate * extra_beds_used_by_children(params[:children].to_i)]
      else
        child_rate = room_rate.child_rates_infants.order(rate: :desc).first&.rate || room_rate.extra_bed_rate
        child_rate = child_rate.zero? ? price_list.sum : child_rate
        [child_rate * extra_beds_used_by_children(params[:infants].to_i)]
      end
    end

    def calculate_infants_rate price_list
      return unless params[:infants].present? || params[:infants] == '0'

      infants_rate = room_rate.child_rates_infants.order(rate: :desc).first&.rate || room_rate.extra_bed_rate
      infants_rate = infants_rate.zero? ? price_list.sum : infants_rate
      [child_rate * extra_beds_used_by_children]
    end

    def adult_rate_by_single_rate_type
      if params[:adults] == '1' && params[:children] == '0' && room_rate.single_supplement?
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements] + [room_rate.default_single_rate]
      elsif params[:adults] == '1' && params[:children] == '0' && room_rate.single_rate?
        @adults_rates = ([(room_rate.default_single_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      else
        @adults_rates = ([(room_rate.default_rate / params[:minimum_stay])] * params[:minimum_stay]) + [get_daily_supplements]
      end

      return @adult_rates if room_rate.extra_beds_for_children_only

      @adults_rates += [room_rate.extra_beds * extra_beds_used_by_adults]
    end

    def extra_beds_used_by_adults
      return 0 if params[:adults].to_i <= params[:max_adults].to_i

      params[:adults].to_i - params[:max_adults].to_i
    end

    def extra_beds_used_by_children num_of_children
      return 0 if params[:adults].to_i + num_of_children <= params[:max_adults].to_i

      (params[:adults].to_i + num_of_children) - params[:max_adults].to_i
    end
end


# case room_rate.open_gds_rate_type
# when 'pppn' || 'pp' || 'pppd' && params[:adult] == '1'
#   return 0 if params[:children] == '1'
#
#   child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
#   price_list.sum + (child_rate.rate * params[:minimum_stay] * (params[:children].to_i - 1))
# when 'pppn' || 'pp' || 'pppd' || 'papn' || 'pa' || 'papd' && (params[:adult].to_i > 1 || extra_beds_used?)
#   child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
#   child_rate.rate * params[:minimum_stay] * params[:children].to_i
