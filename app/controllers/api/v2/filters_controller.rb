class Api::V2::FiltersController < Api::V2::ApiController
  def show
    render json: {
      amenities: Api::V2::AmenitySerializer.new(Amenity.hot.includes(:translations)).serializable_hash,
      experiences: Api::V2::ExperienceSerializer.new(Experience.includes(:translations)).serializable_hash,
      categories: LodgingCategory.all.pluck(:name).reject(&:blank?).to_a,
      countries: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
    }, status: :ok
  end
end
