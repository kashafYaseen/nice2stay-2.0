class Api::V2::TripsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_trip, only: [:show, :update, :destroy]

  def index
    pagy, trips = pagy(current_user.trips.includes({ lodgings: :translations }, :users), items: params[:per_page], page: params[:page])
    render json: Api::V2::TripSerializer.new(trips, params: { lodgings_required: true }).serializable_hash.merge(pagy: pagy), status: :ok
  end

  def show
    render json: Api::V2::TripSerializer.new(@trip,params: { lodgings_required: false, wishlists_required: true }).serialized_json, status: :ok
  end

  def create
    trip = current_user.trips.build(trip_params)
    trip.users << current_user
    if trip.save
      render json: Api::V2::TripSerializer.new(trip, params: { lodgings_required: true }).serialized_json, status: :ok
    else
      unprocessable_entity(trip.errors)
    end
  end

  def update
    if @trip.update(trip_params)
      render json: Api::V2::TripSerializer.new(@trip, params: { lodgings_required: true }).serialized_json, status: :ok
    else
      unprocessable_entity(@trip.errors)
    end
  end

  def destroy
    @trip.destroy
    render json: { removed: @trip.destroyed? }, status: :ok
  end

  private
    def set_trip
      @trip = current_user.trips.find(params[:id])
    end

    def trip_params
      params.require(:trip).permit(
        :name,
        :adults,
        :children,
        :budget,
        :check_in,
        :check_out,
        :visibility,
        :need_advise,
      )
    end
end
