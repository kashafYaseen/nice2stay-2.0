class Meal < ApplicationRecord
  validates :gc_meal_id, presence: true, uniqueness: true
  translates :description
end
