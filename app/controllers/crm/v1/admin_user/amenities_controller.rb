class Crm::V1::AdminUser::AmenitiesController < Crm::V1::ApiController

  before_action :get_amenity, only: %i[edit update destroy]

  def index
    @amenities = Amenity.includes(:translations, :amenity_category, :translations).all
    render json: Crm::V1::AmenitySerializer.new(@amenities).serialized_json, status: :ok
  end

  def new
  end

  def edit
  end

  def create
    @amenity = Amenity.new(amenity_params)
    if @amenity.save
      render json: Crm::V1::AmenitySerializer.new(@amenity).serialized_json, status: :ok
    else
      unprocessable_entity(@amenity.errors)
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
    @amenity = Amenity.friendly.find(params[:amenity_id])
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

    def get_amenity
      @amenity = Amenity.friendly.find(params[:id])
    end

    def amenity_params
      params.require(:amenity).permit(
        :name_en,
        :name_nl,
        :amenity_category_id,
        :slug_en,
        :slug_nl,
        # :add_to_search_filters, #this is an additional attribute
        :hot,
        :icon,
        :image_attributes => [:id, :image]
      )
    end
end
