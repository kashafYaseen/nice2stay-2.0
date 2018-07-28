class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, :set_reservations

  def set_reservations
    return @reservations = current_user.reservations_in_cart if current_user.present?
    @reservations = Reservation.where(id: session[:reservations].split(',')) if session[:reservations].present?
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def locale
    I18n.locale
  end
end
