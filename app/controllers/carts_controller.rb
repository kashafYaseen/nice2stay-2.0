class CartsController < ApplicationController
  before_action :empty_cart, only: [:remove, :destroy, :update]

  def show
    @user = current_user || User.without_login.new
  end

  def remove
    @reservations = ManageCart.new(booking: @booking, user: current_user, cookies: cookies).delete(params[:reservation_id])
    flash.now[:notice] = 'Reservation was removed successfully.'
  end

  def update
    unless current_user.present?
      return render :show unless create_user
    end

    errors = ManageCart.new(booking: @booking, user: (current_user || @user), cookies: cookies).checkout(current_user.present?)

    if errors.present?
      redirect_to carts_path, alert: errors
    else
      redirect_to carts_path, notice: 'Reservations was created successfully.'
    end
  end

  def destroy
    @booking.delete
    redirect_to carts_path, notice: 'Cart was cleared successfully.'
  end

  private
    def empty_cart
      return redirect_to carts_path unless @booking.present?
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

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end
