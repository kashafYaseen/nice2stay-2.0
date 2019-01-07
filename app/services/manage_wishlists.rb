class ManageWishlists
  attr_reader :wishlists
  attr_reader :user

  def initialize(wishlists:, user:)
    @wishlists = wishlists
    @user = user
  end

  def delete(wishlist_id)
    wishlists.find_by_id(wishlist_id).try(:delete)
    set_wishlists
  end

  def checkout
    errors = {}
    wishlists.each do |wishlist|
      unless wishlist.update(user: user, status: :checkout)
        errors[wishlist.name || wishlist.id] = wishlist.errors
      end
    end
    errors
  end

  private
    def set_wishlists
      @wishlists = user.wishlists_active.includes(:lodging).reload
    end
end
