class CartsController < ApplicationController
  before_action :set_reservations
  before_action :empty_cart, only: [:edit, :destroy]

  def show
  end

  def edit
    @reservations.find_by_id(params[:reservation_id]).try(:delete)
    session[:reservations] = @reservations.ids.join(',') if session[:reservations].present?
    redirect_to carts_en_path, notice: 'Reservation was removed successfully.'
  end

  def destroy
    @reservations.delete_all
    session.delete(:reservations) if session[:reservations].present?
    redirect_to carts_en_path, notice: 'Cart was cleared successfully.'
  end

  private
    def set_reservations
      return @reservations = current_user.reservations_in_cart if current_user.present?
      @reservations = Reservation.where(id: session[:reservations].split(',')) if session[:reservations].present?
    end

    def empty_cart
      return redirect_to carts_en_path unless @reservations.present?
    end
end
