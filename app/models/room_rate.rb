class RoomRate < ApplicationRecord
  belongs_to :room_type
  belongs_to :rate_plan

  has_many :availabilities
  has_many :reservations

  enum default_single_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  enum extra_bed_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  delegate :code, to: :rate_plan, prefix: true, allow_nil: true
end
