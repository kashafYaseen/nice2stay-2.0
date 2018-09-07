class Api::V1::AmenitiesController < Api::V1::ApiController
  def create
    @amenity = SaveAmenityDetails.call(params)

    if @amenity.valid?
      render json: @amenity, status: :created
    else
      render json: @amenity.errors, status: :unprocessable_entity
    end
  end
end
