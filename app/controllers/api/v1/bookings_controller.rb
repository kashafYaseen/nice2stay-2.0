class Api::V1::BookingsController < Api::V1::ApiController
  def create
    @booking = SaveBookingDetails.call(params)

    if @booking.persisted?
      render status: :created
    else
      unprocessable_entity(@booking.errors)
    end
  end
end
