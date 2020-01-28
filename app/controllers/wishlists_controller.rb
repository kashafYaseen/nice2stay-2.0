class WishlistsController < ApplicationController
  before_action :authenticate_user!

  def new
    @wishlist = current_user.wishlists.build(wishlist_params)
  end

  def create
    @wishlist = current_user.wishlists.create(wishlist_params)
    flash.now[:notice] = "Accommodation was add to #{@wishlist.trip_name} successfully."
  end

  def destroy
    current_user.wishlists.find_by(trip_id: params[:id], lodging_id: params[:lodging_id]).try(:destroy)
    redirect_to trip_path(params[:id]), notice: 'Accommodation was removed successfully.'
  end

  private
    def wishlist_params
      params.require(:wishlist).permit(:check_in, :check_out, :lodging_id, :adults, :children, :name, :trip_id)
    end
end
