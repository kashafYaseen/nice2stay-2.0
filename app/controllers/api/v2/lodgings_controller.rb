class Api::V2::LodgingsController < Api::V2::ApiController
  before_action :set_lodging, only: [:show]

  def index
    @lodgings = SearchLodgings.call(params)
    render json: Api::V2::LodgingSerializer.new(@lodgings).serialized_json, status: :ok
  end

  def show
    render json: Api::V2::LodgingSerializer.new(@lodging).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.find(params[:id])
    end
end
