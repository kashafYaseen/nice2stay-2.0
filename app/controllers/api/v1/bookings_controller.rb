class Api::V1::BookingsController < Api::V1::ApiController
  def create
    @booking = SaveBookingDetails.call(params)

    if @booking.persisted?
      render status: :created
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end
end
