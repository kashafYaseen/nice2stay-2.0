class Crm::V1::AdminUser::AmenityCategoriesController < Crm::V1::ApiController

  before_action :set_amenity_category, only: %i[edit update destroy]

  def index
    @q = AmenityCategory.ransack(translations_name_cont: params[:query])
    @pagy, @records = pagy(@q.result(distinct: true), items: params[:items], page: params[:page], items: params[:per_page])

    render json: Crm::V1::AmenityCategorySerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
  end

  def edit
  end

  def new
  end

  def create
    amenity_category = AmenityCategory.new(amenity_category_params)
    if amenity_category.save
      render json: Crm::V1::AmenityCategorySerializer.new(amenity_category).serialized_json, status: :ok
    else
      unprocessable_entity(amenity_category.errors)
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
    def set_amenity_category
       @amenity_category = AmenityCategory.find(params[:id])
    end

    def amenity_category_params
      params.require(:amenity_category).permit(:name_en, :name_nl)
    end
end
