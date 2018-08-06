class WishlistsController < ApplicationController
  before_action :empty_wishlist, only: [:remove, :destroy, :update]

  def show
  end

  def create
    @wishlist = Wishlist.create!(wishlist_params.merge(user: current_user))
    save_wishlist_items unless current_user.present?
    flash.now[:notice] = "The wishlist was saved successfully."
  end

  def remove
    @wishlists = ManageWishlists.new(wishlists: @wishlists, user: current_user, cookies: cookies).delete(params[:wishlist_id])
    flash.now[:notice] = 'Wishlist was removed successfully.'
  end

  def update
  end

  def destroy
    @wishlists.delete_all
    cookies.delete(:wishlists) if cookies[:wishlists].present?
    redirect_to wishlists_en_path, notice: 'Wishlists was cleared successfully.'
  end

  private
    def empty_wishlist
      return redirect_to wishlists_en_path unless @wishlists.present?
    end

    def wishlist_params
      params.require(:wishlist).permit(:check_in, :check_out, :lodging_id, :adults, :children)
    end

    def save_wishlist_items
      if cookies[:wishlists].present?
        cookies[:wishlists] += ",#{@wishlist.id}"
      else
        cookies[:wishlists] = @wishlist.id.to_s
      end
      @wishlists = Wishlist.where(id: cookies[:wishlists].split(','))
    end
end
