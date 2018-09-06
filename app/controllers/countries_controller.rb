class CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.friendly.find(params[:id])
  end
end
