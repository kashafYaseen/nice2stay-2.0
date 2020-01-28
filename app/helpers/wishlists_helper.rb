module WishlistsHelper
  def trip_items_count(trips)
    return trips.count if trips.present?
    0
  end
end
