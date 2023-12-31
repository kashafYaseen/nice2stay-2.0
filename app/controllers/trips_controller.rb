class TripsController < ApplicationController
  before_action :authenticate_user!, except: [:public]
  before_action :set_trip, only: [:show, :edit, :update, :destroy]

  def index
    @trips = current_user.trips
  end

  def show
  end

  def new
    @trip = current_user.trips.build
  end

  def create
    @trip = current_user.trips.build(trip_params)
    if @trip.save
      @trip.users << current_user
      redirect_to @trip, notice: 'Trip was created successfully'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @trip.update(trip_params)
      redirect_to @trip, notice: 'Trip was updated successfully'
    else
      render :edit
    end
  end

  def destroy
    @trip.destroy
    redirect_to trips_path, notice: 'Trip was removed successfully'
  end

  def public
    @trip = Trip.everyone.find(params[:id])
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
