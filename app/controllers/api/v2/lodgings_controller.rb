class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_lodging, only: [:show, :options]
  before_action :set_custom_text, only: [:index]

  def index
    @lodgings = SearchLodgings.call(params, @custom_text)
    render json: Api::V2::LodgingSerializer.new(@lodgings).serialized_json, status: :ok
  end

  def show
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging).serialized_json, status: :ok
  end

  def options
    render json: Api::V2::LodgingDetailsSerializer.new(@lodging.lodging_children).serialized_json, status: :ok
  end

  def cumulative_price
    @lodgings = Lodging.where(id: params[:ids].try(:split, ','))
    @lodgings.map{ |lodging| lodging.cumulative_price(params.clone) }
    render json: Api::V2::LodgingSerializer.new(@lodgings).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end

    def set_custom_text
      @custom_text = CustomText.find_by(id: params[:custom_text_id])
    end
end
