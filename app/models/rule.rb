class Rule < ApplicationRecord
  belongs_to :lodging

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active, -> (check_in, check_out) { where("(start_date is ? and end_date is ?) or (start_date <= ? and end_date >= ?) or (start_date <= ? and end_date >= ?)", nil, nil, check_in, check_in, check_out, check_out) }
  scope :collect_search_data, -> { collect { |rule| { start_date: rule.start_date.to_date, end_date: rule.end_date.to_date, flexible_arrival: rule.flexible_arrival, minimum_stay: rule.minimum_stay, weekly_stay: rule.minimum_stay.present?  } } }
end
