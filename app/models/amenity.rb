class Amenity < ApplicationRecord
  belongs_to :amenity_category
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_amenities'

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :slug

  before_save :name_downcase

  scope :hot, -> { where(hot: true) }
  scope :regular, -> { where(hot: false) }

  def name_downcase
    self.name.downcase!
  end
end
