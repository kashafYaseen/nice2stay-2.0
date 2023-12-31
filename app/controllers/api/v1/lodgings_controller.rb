class Api::V1::LodgingsController < Api::V1::ApiController
  before_action :set_lodging, only: [:show, :update]

  def show
    return not_acceptable("Lodging not found") unless @lodging.present?
  end

  def create
    @lodging = SaveLodgingDetails.call(params)
    @lodging.reindex
    Lodging.flush_cached_searched_data

    if @lodging.valid?
      render status: :created
    else
      unprocessable_entity(@lodging.errors)
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { duplicated: true }, status: :unprocessable_entity
  end

  def update
    if @lodging.update(lodging_params)
      render status: :ok
    else
      unprocessable_entity(@lodging.errors)
    end
  end

  def reindex
    Lodging.reindex
    Lodging.flush_cached_searched_data
    render json: { reindex: true }, status: :ok
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
        :slug,
        :name,
        :meta_title,
        :h1,
        :h2,
        :h3,
        :highlight_1,
        :highlight_2,
        :highlight_3,
        :label,
        :summary,
        :location_description,
        :meta_desc,
        :short_desc,
        :published,
        :heads,
        :confirmed_price,
        :include_cleaning,
        :include_deposit,
        :checked,
        :flexible,
        :listed_to,
        :ical_validated,
        :route_updated_at,
        :price_updated_at,
        :status,
        :region_id,
        :images,
        specifications_attributes: [:id, :title, :description],
        reviews_attributes: [:id, :user_id, :stars, :description],
        availabilities_attributes: [:id, :available_on, :check_out_only, prices_attributes: [:id, :amount, :adults, :infants, :children]],
        rules_attributes: [:id, :start_date, :end_date, :days_multiplier, :check_in_days],
        discounts_attributes: [:id, :start_date, :end_date, :reservation_days, :discount_percentage],
      )
    end
end
