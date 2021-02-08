class ChildRate < ApplicationRecord
  belongs_to :rate_plan

  scope :infants, -> { where(age_group: ['Infants (0-1 year)', 'Toddlers (1-3 years)']) }
  scope :children, -> { where.not(age_group: ['Infants (0-1 year)', 'Toddlers (1-3 years)']) }

  enum rate_type: {
    fixed_rate: 0,
    percentage: 1
  }

  enum age_group: {
    infants: 0,
    children: 1
  }
end
