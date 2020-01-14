class Trip < ApplicationRecord
  has_many :trip_members
  has_many :users, through: :trip_members

  has_many :wishlists
  has_many :lodgings, through: :wishlists

  validates :name, presence: true
end
