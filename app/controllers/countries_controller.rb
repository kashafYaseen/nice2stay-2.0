class CountriesController < ApplicationController
  def index
  end

  def show
    @country = Country.friendly.find(params[:id])
    @lodgings = @country.lodgings_country_page
    @custom_texts = @country.custom_texts.country_page
  end
end
