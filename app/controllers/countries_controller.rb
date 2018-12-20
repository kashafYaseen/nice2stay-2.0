class CountriesController < ApplicationController
  def index
  end

  def show
    @country = Country.friendly.find(params[:id])
    @lodgings = @country.lodgings_country_page
    @lodgings.map{|lodging| lodging.cumulative_price(params.clone)}
    @custom_texts = @country.custom_texts.country_page
    @title = @country.meta_title
  end
end
