class Country < ApplicationRecord
  has_many :regions

  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true, uniqueness: true
end
