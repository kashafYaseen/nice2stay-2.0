class CustomText < ApplicationRecord
  belongs_to :country
  belongs_to :region
  belongs_to :experience

  translates :h1_text, :p_text, :meta_title, :meta_description, :category, :seo_path, :seo_path_without_locale, :seo_path_without_country

  delegate :slug, to: :country, prefix: true, allow_nil: true
  delegate :slug, to: :region, prefix: true, allow_nil: true
  delegate :slug, to: :experience, prefix: true, allow_nil: true

  scope :home_page, -> { where(homepage: true) }
  scope :menu, -> { where(navigation_popular: true) }
  scope :country_menu, -> { where(navigation_country: true) }
  scope :country_page, -> { where(country_page: true) }
  scope :region_page, -> { where(region_page: true) }

  def translation_with locale, method
    Globalize.with_locale(locale) do
      return send(method)
    end
  end
end
