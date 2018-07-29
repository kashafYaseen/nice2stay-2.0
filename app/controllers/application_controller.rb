class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, :set_reservations

  def set_reservations
    @reservations = Reservation.where(id: cookies[:reservations].split(',')) if cookies[:reservations].present?
    if current_user.present?
      @reservations.update_all(user_id: current_user.id) if cookies[:reservations].present?
      @reservations = current_user.reservations_in_cart
      cookies.delete(:reservations)
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def locale
    I18n.locale
  end
end
