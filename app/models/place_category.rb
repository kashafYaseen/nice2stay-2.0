class PlaceCategory < ApplicationRecord
  has_many :places

  extend FriendlyId
  friendly_id :name, use: :slugged
end
