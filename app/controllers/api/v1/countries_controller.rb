class Api::V1::CountriesController < Api::V1::ApiController
  def create
#    @country = SaveCountryDetails.call(params)
    @country = Country.first # prevent from creating new records.

    if @country.valid?
      render json: @country, status: :created
    else
      unprocessable_entity(country.errors)
    end
  end
end
