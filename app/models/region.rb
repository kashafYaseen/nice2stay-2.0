class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings
  has_many :custom_texts
  has_many :places
  has_and_belongs_to_many :campaigns
  has_and_belongs_to_many :leads

  include ImageHelper

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :content, :slug, :title, :meta_title
  globalize_accessors

  searchkick text_middle: [:name_en, :name_nl]

  validates :name, presence: true

  default_scope { includes(:translations) }

  scope :active, -> { joins(:country).where(countries: { disable: false }) }

  delegate :name, :regions, :disable, :slug, to: :country, prefix: true, allow_nil: true
  delegate :region_page, to: :lodgings, prefix: true, allow_nil: true

  def search_data
    attributes.merge(
      name_en: name_en,
      name_nl: name_nl,
      title_en: title_en,
      title_nl: title_nl,
      country_slug: country.slug,
      country_name_en: country.name_en,
      country_name_nl: country.name_nl,
      disable: country_disable,
      lodging_count: lodgings.published_parents_count,
    )
  end

  def self.names_with_country
    includes(:country).collect{ |region| ["#{region.name}, #{region.country_name}"] }
  end

  def self.find_or_create_region(country_name, region_name)
    country = Country.find_by(name: country_name)
    country.regions.find_by(name: region_name) if country.present?
  end

  def translated_slugs
    translations.pluck(:slug)
  end
end
