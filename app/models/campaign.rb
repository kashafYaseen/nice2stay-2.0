class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions

  validates :title, :description, presence: true
end
