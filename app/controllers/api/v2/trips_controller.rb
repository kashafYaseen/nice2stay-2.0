class Api::V2::TripsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_trip, only: [:update, :destroy]

  def index
    pagy, trips = pagy(current_user.trips.includes({ lodgings: :translations }, :users), items: params[:per_page], page: params[:page])
    render json: Api::V2::TripSerializer.new(trips).serializable_hash.merge(pagy: pagy), status: :ok
  end

  def create
    trip = current_user.trips.build(trip_params)
    trip.users << current_user
    if trip.save
      render json: Api::V2::TripSerializer.new(trip).serialized_json, status: :ok
    else
      unprocessable_entity(trip.errors)
    end
  end

  def update
    if @trip.update(trip_params)
      render json: Api::V2::TripSerializer.new(@trip).serialized_json, status: :ok
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
      )
    end
end
