class RegionsController < ApplicationController
  def show
    @region = Country.friendly.find(params[:country_id]).regions.friendly.find(params[:id])
    @reservation = Reservation.new
    @lodgings = @region.lodgings_region_page
    @lodgings.map{|lodging| lodging.cumulative_price(params.clone)}
    @custom_texts = @region.custom_texts.region_page
    @title = @region.meta_title
  end
end
