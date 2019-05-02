class FeedbacksController < ApplicationController
  before_action :set_reservation

  def new
    @review = @reservation.review || @reservation.build_review
  end

  def create
    @review = @reservation.build_review(review_params.merge(lodging: @reservation.lodging, user: @reservation.user))
    if @review.save
      redirect_to new_feedback_path(id: params[:id])
    else
      render :new
    end
  end

  private
    def review_params
      params.require(:review).permit(
        :reservation,
        :lodging,
        :user,
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
        { images: [] },
      )
    end

    def set_reservation
      booking = User.last.bookings.build
      return @reservation = Lodging.first.reservations.build(booking: booking)

      id = JsonWebToken.decode(params[:id], ENV['FEEDBACK_TOKEN'])
      if id.present?
        @reservation = Reservation.find(id['reservation_id'])
      else
        return redirect_to page_not_found_path
      end
    end
end
