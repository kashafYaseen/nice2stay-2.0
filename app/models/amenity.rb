class Amenity < ApplicationRecord
  has_and_belongs_to_many :lodgings

  extend FriendlyId
  friendly_id :name, use: :slugged

  before_save :name_downcase

  def name_downcase
    self.name.downcase!
  end
end
