class Api::V2::LodgingDetailsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :h3, :lodging_type, :presentation, :child_name,
             :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc,
             :images, :average_rating, :created_at, :updated_at,
             :minimum_adults, :minimum_children, :beds, :baths, :checked,:including_text,
             :options_text, :payment_terms_text, :deposit_text,
             :highlight_1, :highlight_2, :highlight_3, :description, :customized_dates,
             :setting, :quality, :interior, :service, :communication, :country_name, :region_name,
             :gc_rooms, :guest_centric_id, :guest_centric, :realtime_availability, :gc_username, :gc_password, :channel,
             :extra_beds, :extra_beds_for_children_only

  attribute :summary do |lodging|
    lodging.as_child? ? lodging.parent_summary : lodging.summary
  end

  attribute :not_available_on, unless: proc { |lodging| lodging.as_child? } do |lodging|
    lodging.as_parent? ? lodging.children_not_available_on : lodging.not_available_on
  end

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attributes :options, if: Proc.new { |lodging| lodging.as_parent? } do |lodging|
    Api::V2::LodgingDetailsSerializer.new(lodging.lodging_children.published.includes(:parent, :translations, { price_text: :translations }, { room_rates: { rate_plan: :translations } }, { reviews: [:lodging, :reservation, :user] }))
  end

  attributes :wishlist_id, if: Proc.new { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end

  attributes :reviews, if: Proc.new { |lodging, params| params.present? && params[:reviews].present? } do |lodging, params|
    Api::V2::ReviewSerializer.new(lodging.all_reviews.limit(5))
  end

  attribute :room_rates, if: proc { |lodging| lodging.belongs_to_channel? && !lodging.as_parent? } do |lodging|
    Api::V2::RoomRateSerializer.new(lodging.room_rates.published.with_active_rate_plan)
  end

  attributes :place_categories, if: Proc.new { |lodging, params| params.present? && params[:place_categories] } do |lodging, params|
    Api::V2::PlaceCategorySerializer.new(lodging.place_categories)
  end
end
