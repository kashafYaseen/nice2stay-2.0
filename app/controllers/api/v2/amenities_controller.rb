class Api::V2::AmenitiesController < Api::V2::ApiController
  def index
    if params && params[:lodging_id]
      lodging = Lodging.find(params[:lodging_id])
      render json: Api::V2::AmenitySerializer.new(lodging.amenities.includes(:translations, amenity_category: :translations)).serialized_json, status: :ok
    else
      lodgings = SearchLodgingByIds.call(params[:lodging_ids].try(:split, ',').to_ary)
      total_lodgings = CountTotalLodgings.call(true)
      render json: Api::V2::AmenitySerializer.new(Amenity.all.includes(:translations, amenity_category: :translations), params: { lodgings: lodgings, total_lodgings: total_lodgings }).serialized_json, status: :ok
    end
  end
end
