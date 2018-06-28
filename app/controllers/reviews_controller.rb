class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation
  before_action :check_authorization

  def new
    @review = @reservation.build_review
  end

  def create
    @review = @reservation.build_review(review_params.merge(lodging: @reservation.lodging, user: current_user))
    if @review.save
      redirect_to @reservation.lodging, notice: 'Reivew was created successfully.'
    else
      render :new
    end
  end

  private
    def review_params
      params.require(:review).permit(:reservation, :lodging, :user, :setting, :quality, :interior, :communication, :service, :description, :suggetion, :stars)
    end

    def set_reservation
      @reservation = current_user.reservations.find(params[:reservation_id])
    end

    def check_authorization
      return if @reservation.can_review?(current_user)
      return redirect_to reservations_path, alert: 'Reivew already exist or you are not authorize'
    end
end
