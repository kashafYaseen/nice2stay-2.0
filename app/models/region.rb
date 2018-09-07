class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings
  has_and_belongs_to_many :campaigns

  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick word_start: [:name]

  validates :name, presence: true

  delegate :name, :regions, :slug, to: :country, prefix: true

  def search_data
    attributes.merge(
      country_slug: country_slug,
    )
  end

  def self.names_with_country
    includes(:country).collect{ |region| ["#{region.name}, #{region.country_name}"] }
  end

  def self.find_or_create_region(country_name, region_name)
    country = Country.find_or_create_by(name: country_name)
    country.regions.find_or_create_by(name: region_name)
  end
end
