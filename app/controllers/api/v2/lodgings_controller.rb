class Api::V2::LodgingsController < Api::V1::ApiController
  before_action :set_lodging, only: [:show, :update]

  def show
    return not_acceptable("Lodging not found") unless @lodging.present?
  end

  def index
    @lodgings = SearchLodgings.call(params)
  end

  private
    def set_lodging
      @lodging = Lodging.find_by(id: params[:id])
    end
end
