class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings

  validates :name, presence: true

  delegate :name, :regions, to: :country, prefix: true

  def self.names_with_country
    includes(:country).collect{ |region| ["#{region.name}, #{region.country_name}"] }
  end

  def self.find_or_create_region(country_name, region_name)
    country = Country.find_or_create_by(name: country_name)
    country.regions.find_or_create_by(name: region_name)
  end
end
