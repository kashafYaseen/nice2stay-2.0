class CustomText < ApplicationRecord
  belongs_to :country, optional: true
  belongs_to :region, optional: true
  belongs_to :experience, optional: true

  translates :h1_text, :p_text, :meta_title, :meta_description, :category, :seo_path, :menu_title

  delegate :slug, to: :country, prefix: true, allow_nil: true
  delegate :slug, to: :region, prefix: true, allow_nil: true
  delegate :slug, to: :experience, prefix: true, allow_nil: true

  scope :home_page, -> { includes(:translations).where(homepage: true) }
  scope :popular, -> { where(popular: true) }
  scope :inspiration, -> { where(inspiration: true) }
  scope :menu, -> { includes(:translations).where(navigation_popular: true) }
  scope :country_menu, -> { includes(:translations).where(navigation_country: true) }
  scope :country_page, -> { includes(:translations).where(country_page: true) }
  scope :region_page, -> { includes(:translations).where(region_page: true) }

  def translation_with locale, method
    Globalize.with_locale(locale) do
      return send(method)
    end
  end
end
