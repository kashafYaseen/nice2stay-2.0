class Api::V1::LodgingsController < Api::V1::ApiController
  before_action :set_lodging, only: [:show]

  def show
    return not_acceptable("Lodging not found") unless @lodging.present?
  end

  private
    def set_lodging
      @lodging = Lodging.find_by(id: params[:id])
    end
end
