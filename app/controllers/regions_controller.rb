class RegionsController < ApplicationController
  def show
    @region = Country.friendly.find(params[:country_id]).regions.friendly.find(params[:id])
    @reservation = Reservation.new
  end
end
