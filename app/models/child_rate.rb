class ChildRate < ApplicationRecord
  belongs_to :rate_plan

  scope :infants, -> { where(age_group: ['Infants (0-1 year)', 'Toddlers (1-3 years)']) }
  scope :children, -> { where.not(age_group: ['Infants (0-1 year)', 'Toddlers (1-3 years)']) }

  enum rate_type: {
    fixed_rate: 0,
    percentage: 1
  }

  enum age_group: {
    'Infants (0-1 year)': 0,
    'Toddlers (1-3 years)': 1,
    'Preschoolers (3-5 years)': 2,
    'Middle Childhood (6-11 years)': 3,
    'Young Teens (12-14 years)': 4,
    'Teenagers (15-17 years)': 5
  }
end
