class Crm::V1::AdminUser::LodgingCategoriesController < Crm::V1::AdminUser::ApiController
  before_action :authenticate
  before_action :find_lodging_category, only: %i[update destroy]

  def index
    render json: Crm::V1::LodgingCategorySerializer.new(LodgingCategory.all).serialized_json, status: :ok
  end

  def edit
  end

  def new
  end

  def create
    @lodging_category = LodgingCategory.new(lodging_category_params)
    if @lodging_category.save
      render json: Crm::V1::LodgingCategorySerializer.new(@lodging_category).serialized_json, status: :ok
    else
      unprocessable_entity(@lodging_category.errors)
    end
  end

  def update
    if @lodging_category.update(lodging_category_params)
      render json: Crm::V1::LodgingCategorySerializer.new(@lodging_category).serialized_json, status: :ok
    else
      unprocessable_entity(@lodging_category.errors)
    end
  end

  def destroy
    @lodging_category.destroy
    render json: { removed: @lodging_category.destroyed? }, status: :ok
  end

  private
    def find_lodging_category
       @lodging_category = LodgingCategory.find(params[:id])
    end

    def lodging_category_params
      params.require(:lodging_category).permit(:name)
    end
end
