class Api::V1::ReviewsController < Api::V1::ApiController
  def create
    @review = SaveReviewDetails.call(params)

    if @review.persisted?
      render json: @review, status: :created
    else
      unprocessable_entity(@review.errors)
    end
  end
end
