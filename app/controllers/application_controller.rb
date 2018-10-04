class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, :set_reservations, :set_wishlists, :set_countries, :set_campaigns

  def set_reservations
    booking = Booking.find_by(id: cookies[:booking]) if cookies[:booking].present?
    @reservations = booking.reservations if booking.present? && booking.in_cart

    if current_user.present?
      if @reservations.present? && current_user.bookings_in_cart.present?
        @reservations.update_all(booking_id: current_user.booking_in_cart.id, user_id: current_user.id)
        booking.delete
        cookies.delete(:booking)
      elsif booking.present?
        @reservations.update_all(user_id: current_user.id) if @reservations.present?
        booking.update_columns(user_id: current_user.id)
      end
      @reservations = current_user.booking_in_cart.reservations
    end
  end

  def set_wishlists
    @wishlists = Wishlist.where(id: cookies[:wishlists].split(',')).includes(:lodging) if cookies[:wishlists].present?
    if current_user.present?
      @wishlists.update_all(user_id: current_user.id) if cookies[:wishlists].present?
      @wishlists = current_user.wishlists_active.includes(:lodging)
      cookies.delete(:wishlists)
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def locale
    I18n.locale
  end

  def set_countries
    @countries = Country.enabled
  end

  def set_campaigns
    @homepage_campaigns = Campaign.home_page
  end
end
