class Api::V2::ReviewsController < Api::V2::ApiController
  before_action :set_lodging, only: [:index]
  before_action :authenticate, only: [:create]
  before_action :set_reservation, only: [:create]

  def index
    pagy, reviews = pagy(@lodging.all_reviews.includes(:lodging, :reservation), items: params[:per_page], page: params[:page])
    render json: Api::V2::ReviewSerializer.new(reviews).serializable_hash.merge(pagy: pagy), status: :ok
  end

  def create
    review = @reservation.build_review(review_params.merge(lodging: @reservation.lodging, user: current_user))
    if review.save
      render json: Api::V2::ReviewSerializer.new(review).serialized_json, status: :ok
    else
      unprocessable_entity(review.errors)
    end
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def set_reservation
      @reservation = current_user.reservations.find(params[:reservation_id])
    end

    def review_params
      params.require(:review).permit(
        :setting,
        :quality,
        :interior,
        :communication,
        :service,
        :description,
        :suggetion,
        :stars,
        :title,
        :anonymous,
        :client_published,
        :nice2stay_feedback,
        { photos: [] },
      )
    end
end
