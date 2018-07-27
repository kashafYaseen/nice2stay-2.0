class CartsController < ApplicationController
  before_action :set_reservations

  def show
  end

  private
    def set_reservations
      return unless current_user.present?
      @reservations = current_user.reservations_in_cart
    end
end
