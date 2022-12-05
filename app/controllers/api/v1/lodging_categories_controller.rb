class Api::V1::LodgingCategoriesController < Api::V1::ApiController
  def create
    category = SaveLodgingCategoryDetails.call(params)
  
    if category.valid?
      render json: category, status: :created
    else
      unprocessable_entity(category.errors)
    end
  end
end
