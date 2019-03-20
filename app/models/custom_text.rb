class CustomText < ApplicationRecord
  belongs_to :country, optional: true
  belongs_to :region, optional: true
  belongs_to :experience, optional: true

  has_many :collections, foreign_key: 'parent_id'
  has_many :relatives, through: :collections

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

  def collection_name
    return region.name.capitalize if region.present?
    return country.name.capitalize if country.present?
  end

  def collections
    return region.custom_texts.region_page if region.present?
    return country.custom_texts.country_page if country.present?
    []
  end
end
