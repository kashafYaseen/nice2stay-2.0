class RoomType < ApplicationRecord
  belongs_to :parent_lodging, class_name: 'Lodging'
  has_many :child_lodgings, class_name: 'Lodging'
  has_many :rate_plans
  has_many :availabilities

  scope :by_codes_and_rate_plans, -> (room_type_codes, rate_plan_codes) { joins(:rate_plans).where(room_types: { code: room_type_codes, rate_plans: { code: rate_plan_codes } }) }
end
