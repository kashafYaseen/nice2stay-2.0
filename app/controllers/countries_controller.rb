class CountriesController < ApplicationController
  def index
  end

  def show
    @country = Country.friendly.find(params[:id])
  end
end
