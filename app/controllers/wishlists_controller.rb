class WishlistsController < ApplicationController
  before_action :empty_wishlist, only: [:remove, :destroy, :update, :edit]

  def show
  end

  def create
    @wishlist = Wishlist.create(wishlist_params.merge(user: current_user))
    save_wishlist_items unless current_user.present?
    flash.now[:notice] = "The wishlist was saved successfully."
  end

  def edit
    @user = current_user || User.without_login.new
  end

  def update
    Wishlist.update(params[:wishlist].keys, params[:wishlist].values)
    redirect_to edit_wishlists_en_path, notice: 'Wishlists were updated successfully.'
  end

  def destroy
    @wishlists.delete_all
    cookies.delete(:wishlists) if cookies[:wishlists].present?
    redirect_to wishlists_en_path, notice: 'Wishlists was cleared successfully.'
  end

  def remove
    @wishlists = ManageWishlists.new(wishlists: @wishlists, user: current_user, cookies: cookies).delete(params[:wishlist_id])
    flash.now[:notice] = 'Wishlist was removed successfully.'
  end

  def checkout
    unless current_user.present?
      return render :edit unless create_user
    end

    errors = ManageWishlists.new(wishlists: @wishlists, user: (current_user || @user), cookies: cookies).checkout(current_user.present?)

    if errors.present?
      redirect_to wishlists_en_path, alert: errors
    else
      redirect_to wishlists_en_path, notice: 'Wishlists were created successfully.'
    end
  end

  private
    def empty_wishlist
      return redirect_to wishlists_en_path unless @wishlists.present?
    end

    def wishlist_params
      params.require(:wishlist).permit(:check_in, :check_out, :lodging_id, :adults, :children)
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def save_wishlist_items
      if cookies[:wishlists].present?
        cookies[:wishlists] += ",#{@wishlist.id}"
      else
        cookies[:wishlists] = @wishlist.id.to_s
      end
      @wishlists = Wishlist.where(id: cookies[:wishlists].split(','))
    end

    def create_user
      if params[:create_account].present?
        @user = User.with_login.new(user_params)
      else
        @user = User.without_login.find_or_initialize_by(email: user_params[:email])
        @user.attributes = user_params
        @user.password = @user.password_confirmation = Devise.friendly_token[0, 20]
      end
      return true if @user.save
    end
end
