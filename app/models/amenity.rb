class Amenity < ApplicationRecord

  extend FriendlyId
  friendly_id :name, use: :slugged

  before_save :name_downcase

  def name_downcase
    self.name.downcase!
  end
end
