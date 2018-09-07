class Amenity < ApplicationRecord
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_amenities'

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :slug

  before_save :name_downcase

  def name_downcase
    self.name.downcase!
  end
end
