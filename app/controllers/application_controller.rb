class ApplicationController < ActionController::Base
  skip_before_filter :verify_authenticity_token # FIXME
  protect_from_forgery with: :exception
  before_action :set_locale, :set_booking, :set_wishlists, :set_countries, :set_campaigns, :set_pages

  def set_booking
    @booking = Booking.find_by(id: cookies[:booking], in_cart: true) if cookies[:booking].present?

    if current_user.present?
      if @booking.present?
        @booking.reservations.update_all(booking_id: current_user.booking_in_cart.id) if @booking.reservations.present?
        @booking.delete
        cookies.delete(:booking)
      end
      @booking = current_user.booking_in_cart
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
    @countries = Country.all.includes(:regions)
    @countries_enabled = @countries.enabled
  end

  def set_campaigns
    @homepage_campaigns = Campaign.home_page
  end

  def set_pages
    @pages = Page.all.includes(:translations)
  end
end
