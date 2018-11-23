class Rule < ApplicationRecord
  belongs_to :lodging

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active, -> (check_in, check_out) { where("(start_date is ? and end_date is ?) or (start_date <= ? and end_date >= ?) or (start_date <= ? and end_date >= ?)", nil, nil, check_in, check_in, check_out, check_out) }

  def search_data
    attributes.merge(
      dates: (start_date..end_date).map(&:to_s), check_in_day: lodging.check_in_day,
      minimum_stay: (minimum_stay || 1),
    )
  end
end
