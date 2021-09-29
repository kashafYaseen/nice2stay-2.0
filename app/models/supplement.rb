class Supplement < ApplicationRecord
  belongs_to :lodging #parent accommodations
  has_many :linked_supplements
  has_many :linked_room_rates, through: :linked_supplements, source: :supplementable, source_type: 'RoomRate'
  has_many :linked_lodgings, through: :linked_supplements, source: :supplementable, source_type: 'Lodging'
  has_many :rate_plans, through: :linked_room_rates

  scope :applied_room_rates_supplements, -> (check_in, check_out, guests) { joins(linked_room_rates: :child_lodging).where('(supplements.valid_permanent = true OR (supplements.valid_from <= :check_in AND supplements.valid_till >= :check_out)) AND lodgings.minimum_adults <= :guests AND lodgings.adults >= :guests', guests: guests, check_in: check_in, check_out: check_out).distinct }
  scope :applied_lodgings_supplements, -> (check_in, check_out, guests, symbol) { joins(symbol).where('(supplements.valid_permanent = true OR (supplements.valid_from <= :check_in AND supplements.valid_till >= :check_out)) AND lodgings.minimum_adults <= :guests AND lodgings.adults >= :guests', guests: guests, check_in: check_in, check_out: check_out) }

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

  def type
    return 'checkbox' if ['Per Stay', 'Per Stay Per Day', 'Per Stay Per Night'].include?(self.rate_type)
    return 'select' if ['Per Piece', 'Per Piece Per Day', 'Per Piece Per Night'].include?(self.rate_type)
    'radio'
  end

  def options(guests)
    return (1..maximum_number.to_i).map(&:to_i) if ['Per Piece', 'Per Piece Per Day', 'Per Piece Per Night'].include?(self.rate_type)
    return (1..guests.to_i).map(&:to_i) if ['Per Person', 'Per Person Per Day', 'Per Person Per Night'].include?(self.rate_type)
    [true, false] # for stay rate types
  end
end
