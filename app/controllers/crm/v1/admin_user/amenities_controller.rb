class Crm::V1::AdminUser::AmenitiesController < Crm::V1::ApiController

  before_action :set_amenity, only: %i[edit update destroy update_icon]

  def index
    @q = Amenity.ransack(translations_name_cont: params[:query])
    @pagy, @records = pagy(@q.result(distinct: true), items: params[:items], page: params[:page], items: params[:per_page])

    render json: Crm::V1::AmenitySerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
  end

  def new
    render json: { amenity_categories: AmenityCategory.all}
  end

  def edit
  end

  def create
    amenity = Amenity.new(amenity_params)
    if amenity.save
      render json: Crm::V1::AmenitySerializer.new(amenity).serialized_json, status: :ok
    else
      unprocessable_entity(amenity.errors)
    end
  end

  def update
    if @amenity.update(amenity_params)
      render json: Crm::V1::AmenitySerializer.new(@amenity).serialized_json, status: :ok
    else
      unprocessable_entity(@amenity.errors)
    end
  end

  #to update the icon column only
  def update_icon
    if @amenity.update_column(:icon, amenity_params[:icon])
      render json: { updated: true }, status: :ok
    else
      unprocessable_entity(@amenity.errors)
    end
  end

  def destroy
    @amenity.destroy
    render json: { removed: @amenity.destroyed? }, status: :ok
  end

  private

    def set_amenity
      @amenity = Amenity.friendly.find(params[:id])
    end

    def amenity_params
      params.require(:amenity).permit(
        :name_en,
        :name_nl,
        :amenity_category_id,
        :slug_en,
        :slug_nl,
        :filter_enabled,
        # :add_to_search_filters, #this is an additional attribute
        :hot,
        :icon,
        :image_attributes => [:id, :image]
      )
    end
end
