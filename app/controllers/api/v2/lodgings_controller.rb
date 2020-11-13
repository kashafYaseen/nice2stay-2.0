class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_lodging, only: [:show, :options]
  before_action :set_custom_text, only: [:index]
  before_action :set_total_lodgings, only: [:index]
  before_action :authenticate, only: [:recommendations]

  def index
    @lodgings = SearchLodgings.call(params, @custom_text, true)
    render json: {
      lodgings: Api::V2::LodgingSerializer.new(@lodgings, { params: { amenities: true, experiences: true, reviews: true, current_user: current_user, lodgings: @lodgings, total_lodgings: @total_lodgings } }).serializable_hash.merge(total_lodgings: @lodgings.total_count),
      experiences: Api::V2::ExperienceSerializer.new(Experience.includes(:translations), { params: { lodgings: @lodgings, total_lodgings: @total_lodgings } })
    } , status: :ok
  end

  def show
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging, { params: { current_user: current_user, reviews: true } }).serialized_json, status: :ok
  end

  def options
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging.lodging_children.published).serialized_json, status: :ok
  end

  def cumulative_price
    lodgings = []

    params[:ids].try(:split, ',').each do |id|
      lodging = Lodging.find(id)
      lodging.cumulative_price(params.clone)
      lodgings << lodging
    end

    render json: Api::V2::LodgingSerializer.new(lodgings, { params: { amenities: true, reviews: true } }).serialized_json, status: :ok
  end

  def recommendations
    lodging_slugs, lodgings = current_user.recommended_lodgings, []
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
end
