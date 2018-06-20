class Region < ApplicationRecord
  belongs_to :country
  has_many :lodgings

  validates :name, presence: true
end
