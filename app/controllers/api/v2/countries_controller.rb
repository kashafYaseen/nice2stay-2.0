class Api::V2::CountriesController < Api::V2::ApiController
  def index
    render json: Api::V2::CountrySerializer.new(Country.all.includes(:regions).ordered).serialized_json, status: :ok
  end
end
