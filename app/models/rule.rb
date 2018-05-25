class Rule < ApplicationRecord
  belongs_to :lodging

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active, -> { where("(start_date is ? and end_date is ?) or (start_date <= ? and end_date > ?)", nil, nil, Date.today, Date.today) }
end
