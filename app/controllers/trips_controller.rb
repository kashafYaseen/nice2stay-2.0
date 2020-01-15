class TripsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip, only: [:show]

  def show
  end

  private
    def set_trip
      @trip = current_user.trips.find(params[:id])
    end
end
