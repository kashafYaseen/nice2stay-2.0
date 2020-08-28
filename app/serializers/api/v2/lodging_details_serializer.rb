class Api::V2::LodgingDetailsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :h3, :lodging_type, :presentation, :child_name,
             :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc,
             :images, :thumbnails, :average_rating, :created_at, :updated_at,
             :minimum_adults, :minimum_children, :beds, :baths, :checked,:including_text,
             :particularities_text, :options_text, :payment_terms_text, :deposit_text,
             :highlight_1, :highlight_2, :highlight_3, :description, :customized_dates,
             :setting, :quality, :interior, :service, :communication, :country_name, :region_name,
             :gc_rooms, :guest_centric_id, :guest_centric, :realtime_availability, :gc_username, :gc_password

  attribute :summary do |lodging|
    lodging.as_child? ? lodging.parent_summary : lodging.summary
  end

  attributes :admin_user do |lodging|
    { name: (lodging.admin_user.try(:full_name) || 'Christa'), image: (lodging.admin_user.try(:image) || 'https://imagesnice2stayeurope.s3.amazonaws.com/uploads/image/image/5478/chirsta.jpg' ) }
  end

  attribute :location_description do |lodging|
    lodging.as_child? ? lodging.parent_location_description : lodging.location_description
  end

  attribute :display_price_notice do |lodging|
    lodging.display_price_notice?
  end

  attribute :not_available_on do |lodging|
    lodging.as_parent? ? lodging.children_not_available_on : lodging.not_available_on
  end

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attributes :amenities do |lodging|
    Api::V2::AmenitySerializer.new(lodging.amenities.includes(:translations).uniq)
  end

  attributes :options, if: Proc.new { |lodging| lodging.as_parent? } do |lodging|
    Api::V2::LodgingDetailsSerializer.new(lodging.lodging_children.published.includes(:parent, :translations, { price_text: :translations }))
  end

  attributes :price_details, if: Proc.new { |lodging, params| params.present? && params[:price_params].present? } do |lodging, params|
    Prices::GetInvoiceDetails.call(lodging, params[:price_params])
  end

  attributes :wishlist_id, if: Proc.new { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end

  attributes :reviews, if: Proc.new { |lodging, params| params.present? && params[:reviews].present? } do |lodging, params|
    Api::V2::ReviewSerializer.new(lodging.all_reviews.limit(5))
  end
end
