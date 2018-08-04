class ManageWishlists
  attr_reader :wishlists
  attr_reader :user
  attr_reader :cookies

  def initialize(wishlists:, user:, cookies:)
    @wishlists = wishlists
    @user = user
    @cookies = cookies
  end

  def delete(wishlist_id)
    wishlists.find_by_id(wishlist_id).try(:delete)
    set_wishlists
    update_cookies if cookies[:wishlists].present?
    wishlists
  end

  private
    def set_wishlists
      return @wishlists = user.wishlists.includes(:lodging).reload if user.present?
      @wishlists = Wishlist.where(id: cookies[:wishlists].split(',')).includes(:lodging) if cookies[:wishlists].present?
    end

    def remove_cookie(id)
      cookies[:wishlists] = (cookies[:wishlists].split(',') - [id.to_s]).join(',')
    end

    def update_cookies
      cookies[:wishlists] = wishlists.ids.join(',') if cookies[:wishlists].present?
    end
end
