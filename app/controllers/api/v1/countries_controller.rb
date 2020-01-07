class Api::V1::CountriesController < Api::V1::ApiController
  def create
    @country = SaveCountryDetails.call(params)

    if @country.valid?
      render json: @country, status: :created
    else
      unprocessable_entity(country.errors)
    end
  end
end
