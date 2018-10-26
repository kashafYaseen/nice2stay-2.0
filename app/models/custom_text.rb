class CustomText < ApplicationRecord
  belongs_to :country
  belongs_to :region
  belongs_to :experience

  translates :h1_text, :p_text, :meta_title, :meta_description, :category

  delegate :slug, to: :country, prefix: true, allow_nil: true
  delegate :slug, to: :region, prefix: true, allow_nil: true
  delegate :slug, to: :experience, prefix: true, allow_nil: true

  scope :home_page, -> { where(homepage: true) }
  scope :menu, -> { where(navigation_popular: true) }
  scope :country_menu, -> { where(navigation_country: true) }
  scope :country_page, -> { where(country_page: true) }
  scope :region_page, -> { where(region_page: true) }

  def seo_path(locale, without_locale = nil, without_country = nil)
    path = without_locale.present? ? "" : "#{locale}/"
    path += "#{translated_slug country, locale}/" if country.present? && without_country.nil?
    path += "#{translated_slug region, locale}/" if region.present?

    translation = translations.find_by(locale: locale) || self
    path += "#{translation.category}/" if translation.category?

    path += "#{translated_slug experience, locale}/" if experience.present?
    path
  end

  def translated_slug object, locale
    translation = object.translations.find_by(locale: locale) || object
    translation.slug
  end
end
