class Api::V2::AmenitiesController < Api::V2::ApiController
  def index
    lodgings = SearchLodgingByIds.call(params[:lodging_ids].try(:split, ',').to_ary)
    total_lodgings = CountTotalLodgings.call(true)
    hot_amenities = Amenity.hot.includes(:translations, amenity_category: :translations)
    regular_amenities = Amenity.regular.includes(:translations, amenity_category: :translations)

    render json: {
      hot: Api::V2::AmenitySerializer.new(hot_amenities, params: { lodgings: lodgings, total_lodgings: total_lodgings }).serializable_hash,
      regular: Api::V2::AmenitySerializer.new(regular_amenities, params: { lodgings: lodgings, total_lodgings: total_lodgings }).serializable_hash
    }, status: :ok
  end
end
