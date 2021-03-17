class RoomType < ApplicationRecord
  belongs_to :parent_lodging, class_name: 'Lodging'
  has_many :child_lodgings, class_name: 'Lodging'
  has_many :room_rates
  has_many :rate_plans, through: :room_rates
  has_many :availabilities, through: :room_rates
  has_many :reservations, through: :room_rates
  has_many :cleaning_costs, through: :rate_plans
  has_many :rules, through: :rate_plans
  has_many :prices, through: :availabilities

  delegate :channel, to: :parent_lodging, allow_nil: true, prefix: true

  scope :by_codes, -> (room_type_codes, rate_plan_codes) { joins(:rate_plans).where(code: room_type_codes, rate_plans: { code: rate_plan_codes }) }
end
