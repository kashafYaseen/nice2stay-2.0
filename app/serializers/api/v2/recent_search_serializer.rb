class Api::V2::RecentSearchSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :check_in, :check_out, :adults, :children, :infants, :searchable_id, :searchable_type

  attribute :searchable do |recent_search|
    recent_search.searchable
  end
end
