class Api::V2::BookingsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_booking, only: [:show]

  def index
    old_bookings_pagy, old_bookings           = pagy(current_user.bookings_confirmed.old, page: params[:old_bookings_page], items: 5)
    upcoming_bookings_pagy, upcoming_bookings = pagy(current_user.bookings_confirmed.upcoming, page: params[:upcoming_bookings_page], items: 5)
    requests_pagy, requests                   = pagy(current_user.reservations_non_confirmed.includes(:booking, lodging: :translations), page: params[:requests_page], items: 5)
    options_pagy, options                     = pagy(current_user.reservations_confirmed_options.includes(:booking, lodging: :translations), page: params[:options_page], items: 5)

    render json: {
      old:      Api::V2::BookingSerializer.new(old_bookings).serializable_hash.merge(pagy: old_bookings_pagy),
      upcoming: Api::V2::BookingSerializer.new(upcoming_bookings).serializable_hash.merge(pagy: upcoming_bookings_pagy),
      requests: Api::V2::ReservationSerializer.new(requests).serializable_hash.merge(pagy: requests_pagy),
      options:  Api::V2::ReservationSerializer.new(options).serializable_hash.merge(pagy: options_pagy),
    }, status: :ok
  end

  def show
    render json: Api::V2::BookingSerializer.new(@booking, { params: { reservations: true } }).serialized_json, status: :ok
  end

  private
    def set_booking
      @booking = current_user.bookings.find(params[:id])
    end
end
