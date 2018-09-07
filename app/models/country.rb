class Country < ApplicationRecord
  has_many :regions

  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick word_start: [:name]

  validates :name, presence: true, uniqueness: true
end
