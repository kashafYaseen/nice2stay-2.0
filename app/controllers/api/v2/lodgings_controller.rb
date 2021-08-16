class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_lodging, only: [:show, :options, :calendar_build, :calendar_departure]
  before_action :set_custom_text, only: [:index]
  before_action :set_total_lodgings, only: [:index]
  before_action :authenticate, only: [:recommendations]

  include MonthsDateRange

  def index
    dates = dates_by_months
    @lodgings = ::V2::SearchLodgings.call(params.clone.merge(months_date_range: dates, flexible_dates: flexible_dates(dates)), @custom_text)

    render json: {
      lodgings: Api::V2::LodgingSerializer.new(@lodgings, { params: { experiences: true, current_user: current_user, lodgings: @lodgings, total_lodgings: @total_lodgings, action_name: action_name } }).serializable_hash.merge(total_lodgings: @lodgings.total_count),
      amenities: Api::V2::AmenitySerializer.new(Amenity.includes(:translations, amenity_category: :translations), params: { lodgings: @lodgings, total_lodgings: @total_lodgings })
    }, status: :ok
  end

  def show
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging, { params: { current_user: current_user, reviews: true, action_name: action_name } }).serialized_json, status: :ok
  end

  def options
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging.lodging_children.published).serialized_json, status: :ok
  end

  def cumulative_price
    lodgings = Lodging.where(id: ids).includes({ room_rates: [{ rate_plan: :rule }, :parent_lodging, :child_lodging] }, :translations)
    search_params = params_wrt_flexible_type
    lodgings.each do |lodging|
      if lodging.belongs_to_channel?
        lodging.room_rates.select{ |room_rate| room_rate.publish && !room_rate.rate_plan_expired? }.each do |room_rate|
          room_rate.cumulative_price(search_params.clone)
          lodging.check_in = room_rate.check_in
          lodging.check_out = room_rate.check_out
          lodging.calculated_price = room_rate.calculated_price
          lodging.dynamic_price = room_rate.dynamic_price
          lodging.price_valid = room_rate.price_valid
          lodging.price_errors = room_rate.price_errors
          break if room_rate.price_valid && params[:accom_listing]
        end
      else
        lodging.cumulative_price(search_params.clone)
      end
    end

    render json: Api::V2::CumulativePriceSerializer.new(lodgings, { params: { check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], accom_listing: params[:accom_listing] }}).serialized_json, status: :ok
  end

  def recommendations
    lodging_slugs, lodgings = current_user.recommended_lodgings_for(params[:id]), []
    lodging_slugs.each { |lodging_slug| lodgings << Lodging.friendly.find(lodging_slug[0]) }

    render json: Api::V2::LodgingSerializer.new(lodgings).serialized_json, status: :ok
  end

  def calendar_build
    render json: CalendarBuild.call(lodging: @lodging, params: params), status: :ok
  end

  def calendar_departure
    render json: CalendarDeparture.call(lodging: @lodging, params: params), status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      # @lodging = @lodging.parent if @lodging.parent.present?
    end

    def set_custom_text
      @custom_text = CustomText.find_by(id: params[:custom_text_id])
    end

    def set_total_lodgings
      @total_lodgings = CountTotalLodgings.call(true)
    end

    def ids
      params[:ids].try(:split, ',')
    end
end
