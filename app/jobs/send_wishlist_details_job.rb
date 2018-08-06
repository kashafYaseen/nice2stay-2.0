class SendWishlistDetailsJob < ApplicationJob
  queue_as :default

  def perform(wishlist_id)
    SendWishlistDetails.call(Wishlist.find_by(id: wishlist_id))
  end
end
