class Api::V2::PlaceSerializer
  include FastJsonapi::ObjectSerializer
  attributes  :id, :address, :spotlight, :header_dropdown, :short_desc,
              :short_desc_nav, :images, :latitude, :longitude, :country_id,
              :region_id, :place_category_id, :created_at, :updated_at, :publish,
              :details, :description, :name, :slug

  attribute :distance, if: proc { |place, params| params.present? } do |place, params|
    place.distance_from(params[:lodgings])
  end
end
