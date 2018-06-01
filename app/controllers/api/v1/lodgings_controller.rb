class Api::V1::LodgingsController < Api::V1::ApiController
  before_action :set_lodging, only: [:show]

  def show
    return not_acceptable("Lodging not found") unless @lodging.present?
  end

  def create
    @lodging = Lodging.new(lodging_params)
    if @lodging.save
      render status: :created
    else
      render json: @lodging.errors, status: :unprocessable_entity
    end
  end

  private
    def set_lodging
      @lodging = Lodging.find_by(id: params[:id])
    end

    def lodging_params
      params.require(:lodging).permit(:street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude, :adults, :children, :infants, :lodging_type)
    end
end
