class Dashboard::ReviewsController < DashboardController
  before_action :set_reservation
  before_action :check_authorization_to_create, only: [:new, :create]
  before_action :set_review, only: [:edit, :update, :destroy]

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

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to dashboard_reservations_path, notice: 'Reivew was updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to dashboard_reservations_path, notice: 'Reivew was removed successfully.'
  end

  private
    def review_params
      params.require(:review).permit(:reservation, :lodging, :user, :setting, :quality, :interior, :communication, :service, :description, :suggetion, :stars, :title)
    end

    def set_reservation
      @reservation = current_user.reservations.find(params[:reservation_id])
    end

    def set_review
      @review = @reservation.review
    end

    def check_authorization_to_create
      return if @reservation.can_review?(current_user)
      return redirect_to dashboard_reservations_path, alert: 'Reivew already exist or you are not authorize'
    end
end
