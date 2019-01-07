class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :empty_wishlist, only: [:remove, :destroy, :update, :edit]
  before_action :set_wishlist, only: [:edit, :update]

  def show
  end

  def create
    @wishlist = current_user.wishlists.create(wishlist_params)
  end

  def edit
  end

  def update
    if @wishlist.update(wishlist_params)
      redirect_to wishlists_path, notice: 'Wishlist was updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @wishlists.delete_all
    redirect_to wishlists_path, notice: 'Wishlists was cleared successfully.'
  end

  def remove
    @wishlists = ManageWishlists.new(wishlists: @wishlists, user: current_user).delete(params[:wishlist_id])
    flash.now[:notice] = 'Wishlist was removed successfully.'
  end

  def checkout
    errors = ManageWishlists.new(wishlists: @wishlists, user: current_user).checkout

    if errors.present?
      redirect_to wishlists_path, alert: errors
    else
      redirect_to wishlists_path, notice: 'Wishlists were created successfully.'
    end
  end

  private
    def empty_wishlist
      return redirect_to wishlists_path unless @wishlists.present?
    end

    def wishlist_params
      params.require(:wishlist).permit(:check_in, :check_out, :lodging_id, :adults, :children, :name)
    end

    def set_wishlist
      @wishlist = @wishlists.find(params[:wishlist_id])
    end
end
