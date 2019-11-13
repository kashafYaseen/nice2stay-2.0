class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_lodging, only: [:show]

  def index
    @lodgings = SearchLodgings.call(params)
    render json: Api::V2::LodgingSerializer.new(@lodgings).serialized_json, status: :ok
  end

  def show
    render json: Api::V2::LodgingSerializer.new(@lodging, { params: { rooms: true } }).serialized_json, status: :ok
  end

  def cumulative_price
    @lodgings = Lodging.where(id: params[:ids].try(:split, ','))
    @lodgings.map{ |lodging| lodging.cumulative_price(params.clone) }
    render json: Api::V2::LodgingSerializer.new(@lodgings).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.find(params[:id])
    end
end
