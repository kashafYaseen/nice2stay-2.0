class Api::V1::PlacesController < Api::V1::ApiController
  def create
    @place = SavePlaceDetails.call(params)

    if @place.valid?
      render json: @place, status: :created
    else
      unprocessable_entity(@place.errors)
    end
  end
end
