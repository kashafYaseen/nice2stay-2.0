class RegionsController < ApplicationController
  def show
    @region = Country.friendly.find(params[:country_id]).regions.friendly.find(params[:id])
    @reservation = Reservation.new
    @lodgings = @region.lodgings_region_page
  end
end
