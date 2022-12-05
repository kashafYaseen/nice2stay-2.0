class PlaceCategory < ApplicationRecord
  has_many :places
  has_and_belongs_to_many :lodgings, join_table: 'lodging_place_categories'

  extend FriendlyId
  friendly_id :name, use: :slugged

  translates :name, :slug
end
