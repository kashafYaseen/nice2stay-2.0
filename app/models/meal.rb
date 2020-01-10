class Meal < ApplicationRecord
  validates :gc_meal_id, presence: true, uniqueness: true
  translates :description, :name
  globalize_accessors locales: [:en, :nl], attributes: [:description, :name]
end
