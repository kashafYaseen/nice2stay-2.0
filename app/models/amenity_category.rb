class AmenityCategory < ApplicationRecord
  has_many :amenities

  translates :name
  globalize_accessors

  validates :name, presence: true, uniqueness: true
end
