class CalculateSupplementsPrices
  attr_reader :supplement,
              :params,
              :selected_supplements_params

  def self.call(supplement:, params:)
    new(supplement: supplement, params: params).call
  end

  def initialize(supplement:, params:)
    @supplement = supplement
    @params = params
    # @selected_supplements_params = JSON.parse(params[:selected_supplements]).map {|sup| sup.transform_keys(&:to_sym)} if params[:selected_supplements].present?
    # @selected_supplement_params = params[:selectd_supplement]
  end

  def call
    return if supplement.blank? || params.blank?
    calculate_price
  end

  private
    def calculate_price
      calculated_data = {}
      sup = !!params[:supplements] ? params[:supplements].find { |sup| sup[:id] == @supplement.id } : nil

      case supplement.rate_type
        when 'Per Piece', 'Per Piece Per Night', 'Per Piece Per Day'
          params[:quantity] = sup ? sup[:quantity] : params[:quantity].to_i
          params[:quantity] = supplement.maximum_number if params[:quantity] > supplement.maximum_number
          calculated_data[:calculated_price] = supplement.rate * params[:quantity]
          calculated_data[:calculated_price] *= stay unless supplement.rate_type == 'Per Piece'
          calculated_data[:quantity] = params[:quantity]
        when 'Per Person', 'Per Person Per Night', 'Per Person Per Day'
          params[:selected_adults] =  sup ? sup[:selected_adults] : params[:selected_adults].to_i
          params[:selected_children] =  sup ? sup[:selected_children] : params[:selected_children].to_i
          calculated_data[:calculated_price] = supplement.rate * selected_guests
          calculated_data[:calculated_price] *= stay unless supplement.rate_type == 'Per Person'
          calculated_data[:selected_adults] = params[:selected_adults]
          calculated_data[:selected_children] = params[:selected_children]
        else
          calculated_data[:calculated_price] = supplement.rate
          calculated_data[:calculated_price] *= stay unless supplement.rate_type == 'Per Stay'
      end

      calculated_data
    end

    def stay
      total_night = (Date.parse(params[:check_out]) - Date.parse(params[:check_in])).to_i
      rate_type_involves_day? ? total_night + 1 : total_night
    end

    def rate_type_involves_day?
      ['Per Piece Per Day', 'Per Person Per Day', 'Per Stay Per Day'].include?(supplement.rate_type)
    end

    def selected_guests
      params[:selected_adults] + params[:selected_children]
    end
end
