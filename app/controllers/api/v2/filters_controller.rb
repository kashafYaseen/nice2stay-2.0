class Api::V2::FiltersController < Api::V2::ApiController
  def show
    render json: {
      amenities: Api::V2::AmenitySerializer.new(Amenity.hot.includes(:translations)).serializable_hash,
      experiences: Api::V2::ExperienceSerializer.new(Experience.includes(:translations)).serializable_hash,
      categories: Lodging.lodging_types,
    }, status: :ok
  end
end
