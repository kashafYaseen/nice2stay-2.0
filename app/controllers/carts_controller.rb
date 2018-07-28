class CartsController < ApplicationController
  before_action :authenticate_user!, only: [:update]
  before_action :empty_cart, only: [:remove, :destroy]

  def show
  end

  def remove
    @reservations.find_by_id(params[:reservation_id]).try(:delete)
    session[:reservations] = @reservations.ids.join(',') if session[:reservations].present?
    redirect_to carts_en_path, notice: 'Reservation was removed successfully.'
  end

  def update
    @errors = {}
    @reservations.each do |reservation|
      unless reservation.update(user: current_user, booking_status: :prebooking)
        @errors[reservation.id] = reservation.errors
      end
    end

    if @errors.present?
      redirect_to carts_en_path, alert: @errors
    else
      redirect_to carts_en_path, notice: 'Reservations was created successfully.'
    end
  end

  def destroy
    @reservations.delete_all
    session.delete(:reservations) if session[:reservations].present?
    redirect_to carts_en_path, notice: 'Cart was cleared successfully.'
  end

  private
    def empty_cart
      return redirect_to carts_en_path unless @reservations.present?
    end
end
