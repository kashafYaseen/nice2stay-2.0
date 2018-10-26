class CustomText < ApplicationRecord
  translates :h1_text, :p_text, :meta_title, :meta_description, :redirect_url, :country, :region, :category, :experience

  def seo_path(locale)
    translation = translations.find_by(locale: locale) || self
    path = ""
    path += "/#{translation.country}" if translation.country?
    path += "/#{translation.region}" if translation.region?
    path += "/#{translation.category}" if translation.category?
    path += "/#{translation.experience}" if translation.experience?
    path
  end
end
