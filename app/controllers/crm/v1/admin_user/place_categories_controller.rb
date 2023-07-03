class Crm::V1::AdminUser::PlaceCategoriesController < Crm::V1::ApiController

  before_action :find_place_category, only: [:update, :destroy]

  def index
    render json: Crm::V1::PlaceCategorySerializer.new(PlaceCategory.all).serialized_json, status: :ok
  end

  def edit
  end

  def new
  end

  def create
    @place_category = PlaceCategory.new(place_category_params)
    if @place_category.save
      render json: Crm::V1::PlaceCategorySerializer.new(@place_category).serialized_json, status: :ok
    else
      unprocessable_entity(@place_category.errors)
    end
  end

  def update
    if @place_category.update(place_category_params)
      render json: Crm::V1::PlaceCategorySerializer.new(@place_category).serialized_json, status: :ok
    else
      unprocessable_entity(@place_category.errors)
    end
  end

  def destroy
    @place_category.destroy
    render json: { removed: @place_category.destroyed? }, status: :ok
  end

  private
    def find_place_category
       @place_category = PlaceCategory.friendly.find(params[:id])
    end

    def place_category_params
      params.require(:place_category).permit(:name, :color_code)
    end
end