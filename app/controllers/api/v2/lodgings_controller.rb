class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_lodging, only: [:show, :options, :calendar_build]
  before_action :set_custom_text, only: [:index]
  before_action :set_total_lodgings, only: [:index]
  before_action :authenticate, only: [:recommendations]

  def index
    @lodgings = SearchLodgings.call(params, @custom_text, params[:only_parent])
    render json: {
      lodgings: Api::V2::LodgingSerializer.new(@lodgings, { params: { experiences: true, current_user: current_user, lodgings: @lodgings, total_lodgings: @total_lodgings, action_name: action_name } }).serializable_hash.merge(total_lodgings: @lodgings.total_count),
      amenities: Api::V2::AmenitySerializer.new(Amenity.includes(:translations, amenity_category: :translations), params: { lodgings: @lodgings, total_lodgings: @total_lodgings })
    } , status: :ok
  end

  def show
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging, { params: { current_user: current_user, reviews: true, action_name: action_name } }).serialized_json, status: :ok
  end

  def options
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging.lodging_children.published).serialized_json, status: :ok
  end

  def cumulative_price
    lodgings = Lodging.where(id: ids).includes({ lodging_children: [{ room_rates: %i[parent_lodging rate_plan child_lodging] }, :translations] }, { children_room_rates: %i[parent_lodging rate_plan child_lodging] })

    lodgings.each do |lodging|
      if lodging.belongs_to_channel?
        room_rates = lodging.as_parent? ? lodging.children_room_rates : lodging.room_rates
        room_rates.select{ |room_rate| room_rate.publish && room_rate.rate_enabled }.each do |room_rate|
          room_rate.cumulative_price(params.clone)
        end
      elsif lodging.as_parent?
        lodging.lodging_children.each do |lodging|
          lodging.cumulative_price(params.clone)
        end
      else
        lodging.cumulative_price(params.clone)
      end
    end

    render json: Api::V2::CumulativePriceSerializer.new(lodgings, { params: { check_in: params[:check_in], check_out: params[:check_out] }}).serialized_json, status: :ok
  end

  def recommendations
    lodging_slugs, lodgings = current_user.recommended_lodgings_for(params[:id]), []
    lodging_slugs.each { |lodging_slug| lodgings << Lodging.friendly.find(lodging_slug[0]) }

    render json: Api::V2::LodgingSerializer.new(lodgings).serialized_json, status: :ok
  end

  def calendar_build
    render json: CalendarBuild.call(lodging: @lodging, params: params), status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
    end

    def set_custom_text
      @custom_text = CustomText.find_by(id: params[:custom_text_id])
    end

    def set_total_lodgings
      @total_lodgings = CountTotalLodgings.call(params[:only_parent])
    end

    def ids
      params[:ids].try(:split, ',')
    end
end
