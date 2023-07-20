class Crm::V1::AdminUser::AmenityCategoriesController < Crm::V1::ApiController

  before_action :find_amenity_category, only: %i[edit update destroy]

  def index
    render json: Crm::V1::AmenityCategorySerializer.new(AmenityCategory.all).serialized_json, status: :ok
  end

  def edit
  end

  def new
  end

  def create
    @amenity_category = AmenityCategory.new(amenity_category_params)
    if @amenity_category.save
      render json: Crm::V1::AmenityCategorySerializer.new(@amenity_category).serialized_json, status: :ok
    else
      unprocessable_entity(@amenity_category.errors)
    end
  end

  def update
    if @amenity_category.update(amenity_category_params)
      render json: Crm::V1::AmenityCategorySerializer.new(@amenity_category).serialized_json, status: :ok
    else
      unprocessable_entity(@amenity_category.errors)
    end
  end

  def destroy
    @amenity_category.destroy
    render json: { removed: @amenity_category.destroyed? }, status: :ok
  end

  private
    def find_amenity_category
       @amenity_category = AmenityCategory.find(params[:id])
    end

    def amenity_category_params
      params.require(:amenity_category).permit(:name)
    end
end
