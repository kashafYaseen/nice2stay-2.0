class Api::V2::ReservationsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_option

  def accept_option
    if @option.update_columns(booking_status: :booked, book_option: :customer)
      SendBookingDetailsJob.perform_later(@option.booking_id)
    end
    render json: Api::V2::ReservationSerializer.new(@option).serializable_hash, status: :ok
  end

  def cancel_option
    if @option.update_columns(request_status: :canceled, canceled: true, canceled_by: :customer, cancel_option_reason: cancel_option_reason[:cancel_option_reason])
      SendBookingDetailsJob.perform_later(@option.booking_id)
    end
    render json: Api::V2::ReservationSerializer.new(@option).serializable_hash, status: :ok
  end

  private
    def set_option
      @option = current_user.reservations_confirmed_options.find(params[:id])
    end

    def cancel_option_reason
      params.require(:reservation).permit(:cancel_option_reason)
    end
end
