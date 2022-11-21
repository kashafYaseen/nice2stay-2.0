class CancellationPolicy < ApplicationRecord
  belongs_to :rate_plan

  enum cancellation_type: {
    within: 0,
    until: 1 }
end
