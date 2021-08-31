class ApplicationController < ActionController::Base
  before_action :prepare_exception_notifier
  protect_from_forgery prepend: true, with: :exception
  before_action :set_locale, :set_booking, :set_wishlists, :set_countries, :set_custom_texts, :set_pages
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_token_authenticity

  def set_booking
    @booking = Booking.find_by(id: cookies[:booking], in_cart: true) if cookies[:booking].present?

    if current_user.present?
      if @booking.present?
        @booking.reservations.update_all(booking_id: current_user.booking_in_cart.id) if @booking.reservations.present?
        @booking.delete
        cookies.delete(:booking)
      end
      @booking = current_user.booking_in_cart unless controller_name == 'Carts' && action_name == 'details'
    end
  end

  def set_wishlists
    @wishlists = current_user.wishlists_active.includes(:lodging) if current_user.present?
    @cart_trips = current_user.trips if current_user.present?
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def locale
    I18n.locale
  end

  def set_countries
    @countries = Country.all.includes(:regions).ordered
    @countries_enabled = @countries.enabled
  end

  def set_custom_texts
    @menu_custom_texts = CustomText.menu
  end

  def set_pages
    @pages = Page.not_private.includes(:translations)
  end

  def handle_token_authenticity
    redirect_back fallback_location: root_path, alert: "Unable to process your request. Please try again"
  end

  private
    def prepare_exception_notifier
      request.env["exception_notifier.exception_data"] = {
        current_user: current_user,
        current_visit: current_visit,
      }
    end
end
