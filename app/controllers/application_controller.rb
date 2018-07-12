class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, :set_countries

  def set_countries
   @countries = Country.all.includes(:regions)
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def locale
    I18n.locale
  end
end
