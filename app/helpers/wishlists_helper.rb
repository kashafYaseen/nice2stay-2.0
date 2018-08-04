module WishlistsHelper
  def wishlist_items_count(wishlists)
    return wishlists.count if wishlists.present?
    0
  end
end
