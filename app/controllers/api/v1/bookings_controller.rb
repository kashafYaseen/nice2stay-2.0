class Api::V1::BookingsController < Api::V1::ApiController
  def create
    @booking, result = SaveBookingDetails.call(params)

    if result
      render status: :created
    else
      render json: @booking.errors, status: :unprocessable_entity
    end
  end
end
