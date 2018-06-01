class Rule < ApplicationRecord
  belongs_to :lodging

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active, -> (check_in, check_out) { where("(start_date is ? and end_date is ?) or (start_date <= ? and end_date >= ?) or (start_date <= ? and end_date >= ?)", nil, nil, check_in, check_in, check_out, check_out) }
end
