class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings

  validates :name, presence: true

  delegate :name, to: :country, prefix: true

  def self.names_with_country
    all.collect{ |u| ["#{u.name}, #{u.country_name}", "#{u.name}, #{u.country_name}"] }
  end

  def self.find_or_create_region(country_name, region_name)
    country = Country.find_or_create_by(name: country_name)
    country.regions.find_or_create_by(name: region_name)
  end
end
