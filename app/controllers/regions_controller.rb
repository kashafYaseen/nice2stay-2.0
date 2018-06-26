class RegionsController < ApplicationController
  def show
    @region = Country.find(params[:country_id]).regions.find(params[:id])
    @reservation = Reservation.new
  end
end
