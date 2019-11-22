class Api::V2::ReviewsController < Api::V2::ApiController
  before_action :set_lodging

  def index
    pagy, reviews = pagy(@lodging.all_reviews.includes(:lodging, :reservation), items: params[:per_page], page: params[:page])
    render json: Api::V2::ReviewSerializer.new(reviews).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def price_options
      { params: { price_params: params } }
    end
end
