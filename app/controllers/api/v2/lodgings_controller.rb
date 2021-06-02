class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_lodging, only: [:show, :options]
  before_action :set_custom_text, only: [:index]
  before_action :set_total_lodgings, only: [:index]
  before_action :authenticate, only: [:recommendations]

  def index
    @lodgings = SearchLodgings.call(params, @custom_text, params[:only_parent])
    render json: {
      lodgings: Api::V2::LodgingSerializer.new(@lodgings, { params: { experiences: true, current_user: current_user, lodgings: @lodgings, total_lodgings: @total_lodgings, action_name: action_name } }).serializable_hash.merge(total_lodgings: @lodgings.total_count),
      experiences: Api::V2::ExperienceSerializer.new(Experience.includes(:translations), { params: { lodgings: @lodgings, total_lodgings: @total_lodgings } })
    } , status: :ok
  end

  def show
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging, { params: { current_user: current_user, reviews: true, action_name: action_name } }).serialized_json, status: :ok
  end

  def options
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging.lodging_children.published).serialized_json, status: :ok
  end

  def cumulative_price
    lodgings = Lodging.where(id: ids).includes(:lodging_children, { children_room_rates: %i[parent_lodging rate_plan child_lodging] }, { room_rates: %i[parent_lodging rate_plan child_lodging] })

    lodgings.each do |lodging|
      next if lodging.as_parent?

      if lodging.belongs_to_channel?
        lodging.room_rates.select(&:publish).each do |room_rate|
          room_rate.cumulative_price(params.clone)
        end
      else
        lodging.cumulative_price(params.clone)
      end
    end

    render json: Api::V2::LodgingSerializer.new(lodgings, { params: { adults: params[:adults], children: params[:children], nights: (params[:check_out].to_date - params[:check_in].to_date).to_f, check_in: params[:check_in], check_out: params[:check_out], rooms: params[:rooms], action_name: action_name } }).serialized_json, status: :ok
  end

  def recommendations
    lodging_slugs, lodgings = current_user.recommended_lodgings_for(params[:id]), []
    lodging_slugs.each { |lodging_slug| lodgings << Lodging.friendly.find(lodging_slug[0]) }

    render json: Api::V2::LodgingSerializer.new(lodgings).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
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
