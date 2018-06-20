class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings

  validates :name, presence: true

  delegate :name, to: :country, prefix: true

  def self.names_with_country
    all.collect{ |u| ["#{u.name}, #{u.country_name}", "#{u.name}, #{u.country_name}"] }
  end
end
