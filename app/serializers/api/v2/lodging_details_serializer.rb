class Api::V2::LodgingDetailsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :h3, :lodging_type, :presentation, :child_name,
             :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc,
             :images, :thumbnails, :average_rating, :created_at, :updated_at,
             :minimum_adults, :minimum_children, :beds, :baths, :checked,:including_text,
             :particularities_text, :options_text, :payment_terms_text, :deposit_text,
             :highlight_1, :highlight_2, :highlight_3, :description, :customized_dates,
             :setting, :quality, :interior, :service, :communication

  attribute :summary do |lodging|
    lodging.as_child? ? lodging.parent_summary : lodging.summary
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
    Api::V2::AmenitySerializer.new(lodging.amenities.includes(:translations))
  end
end
