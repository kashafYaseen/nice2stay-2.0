class CartsController < ApplicationController
  before_action :set_reservations

  def show
  end

  def destroy
    return unless @reservations.present?
    redirect_to carts_en_path, notice: 'Cart was cleared successfully.' if @reservations.delete_all
  end

  private
    def set_reservations
      return unless current_user.present?
      @reservations = current_user.reservations_in_cart
    end
end
