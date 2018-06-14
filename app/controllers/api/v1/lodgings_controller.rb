class Api::V1::LodgingsController < Api::V1::ApiController
  before_action :set_lodging, only: [:show, :update]

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

  def update
    if @lodging.update(lodging_params)
      render status: :ok
    else
      render json: @lodging.errors, status: :unprocessable_entity
    end
  end

  private
    def set_lodging
      @lodging = Lodging.find_by(id: params[:id])
    end

    def lodging_params
      params.require(:lodging).permit(
        :street,
        :city,
        :zip,
        :state,
        :beds,
        :baths,
        :sq__ft,
        :sale_date,
        :price,
        :latitude,
        :longitude,
        :adults,
        :children,
        :infants,
        :lodging_type,
        :title,
        :subtitle,
        :description,
        :owner_id,
        specifications_attributes: [:id, :title, :description],
        reviews_attributes: [:id, :user_id, :stars, :description],
        availabilities_attributes: [:id, :available_on, :check_out_only, prices_attributes: [:id, :amount, :adults, :infants, :children]],
        rules_attributes: [:id, :start_date, :end_date, :days_multiplier, :check_in_days],
        discounts_attributes: [:id, :start_date, :end_date, :reservation_days, :discount_percentage],
      )
    end
end
