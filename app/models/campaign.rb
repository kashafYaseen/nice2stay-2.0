class Campaign < ApplicationRecord
  validates :title, :description, presence: true
end
