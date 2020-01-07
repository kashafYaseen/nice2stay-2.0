class AmenityCategory < ApplicationRecord
  has_many :amenities

  translates :name
end
