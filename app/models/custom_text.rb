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

  def filters
    {
      experiences: { slug: experience_slug, id: experience_id },
      country: { slug: country_slug, id: country_id },
      region: { slug: region_slug, id: region_id },
      lodging_type: { slug: lodging_type(category) },
      discounts: special_offer?,
    }
  end

  def lodging_type(type)
    return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
    return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
    return 'bnb' if ["boutique-hotels", "boutique-hotels", "bnb"].include?(type)
  end
end
