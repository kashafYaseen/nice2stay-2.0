class ChildRate < ApplicationRecord
  belongs_to :rate_plan

  enum rate_type: {
    fixed_rate: 0,
    percentage: 1
  }

  enum age_group: {
    infants: 0,
    children: 1
  }
end
