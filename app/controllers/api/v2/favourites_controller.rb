class Api::V2::FavouritesController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_wishlist, only: [:destroy]

  def index
    pagy, wishlists = pagy(current_user.wishlists_active.includes(lodging: :translations), items: params[:per_page], page: params[:page])
    render json: Api::V2::WishlistSerializer.new(wishlists).serializable_hash.merge(pagy: pagy), status: :ok
  end

  def create
    wishlist = current_user.wishlists.build(wishlist_params)
    if wishlist.save
      render json: Api::V2::WishlistSerializer.new(wishlist).serialized_json, status: :ok
    else
      unprocessable_entity(wishlist.errors)
    end
  end

  def destroy
    @wishlist.destroy
    render json: { removed: @wishlist.destroyed? }, status: :ok
  end

  private
    def set_wishlist
      @wishlist = current_user.wishlists.find(params[:id])
    end

    def wishlist_params
      params.require(:wishlist).permit(:check_in, :check_out, :lodging_id, :adults, :children)
    end
end
