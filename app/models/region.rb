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

  searchkick text_middle: [:name_en, :name_nl]

  validates :name, presence: true

  default_scope { includes(:translations) }

  scope :active, -> { joins(:country).where(countries: { disable: false }) }

  delegate :name, :regions, :disable, :slug, to: :country, prefix: true, allow_nil: true
  delegate :region_page, to: :lodgings, prefix: true, allow_nil: true

  def search_data
    attributes.merge(**associations_search_data, **translations_search_data)
  end

  def associations_search_data
    { country_slug: country_slug, disable: country_disable }
  end

  def translations_search_data
    data = {}
    translations.each do |translation|
      data.merge!({
        "title_#{translation.locale}": (translation.title || title),
        "name_#{translation.locale}": (translation.name || name),
      })
    end
    data
  end

  def self.names_with_country
    includes(:country).collect{ |region| ["#{region.name}, #{region.country_name}"] }
  end

  def self.find_or_create_region(country_name, region_name)
    country = Country.find_or_create_by(name: country_name)
    country.regions.find_or_create_by(name: region_name)
  end

  def translated_slugs
    translations.pluck(:slug)
  end
end
