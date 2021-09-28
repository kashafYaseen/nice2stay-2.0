class Supplement < ApplicationRecord
  belongs_to :lodging #parent accommodations
  has_many :linked_supplements
  has_many :linked_room_rates, through: :linked_supplements, source: :supplementable, source_type: 'RoomRate'
  has_many :rate_plans, through: :linked_room_rates

  translates :name, :description
  globalize_accessors

  enum supplement_type: {
    optional: 0,
    mandatory: 1
  }

  enum rate_type: {
    'Per Piece': 0,
    'Per Piece Per Day': 1,
    'Per Piece Per Night': 2,
    'Per Person': 3,
    'Per Person Per Day': 4,
    'Per Person Per Night': 5,
    'Per Stay': 6,
    'Per Stay Per Day': 7,
    'Per Stay Per Night': 8,
  }
end
