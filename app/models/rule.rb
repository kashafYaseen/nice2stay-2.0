class Rule < ApplicationRecord
  belongs_to :lodging

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active, -> (check_in, check_out) { where("((start_date is :nil and end_date is :nil) or (start_date <= :start_date and end_date >= :end_date) or (start_date <= :start_date and end_date >= :end_date)) AND (checkin_day = :checkin_day or checkin_day = 'any')", nil: nil, start_date: check_in, end_date: check_out, checkin_day: check_in.strftime("%A").downcase) }

  enum checkin_day: {
    any: 'any',
    monday: 'monday',
    tuesday: 'tuesday',
    wednesday: 'wednesday',
    thursday: 'thursday',
    friday: 'friday',
    saturday: 'saturday',
    sunday: 'sunday',
  }

  def search_data
    attributes.merge(
      dates: (start_date..end_date).map(&:to_s), check_in_day: lodging.check_in_day,
      minimum_stay: (minimum_stay || 7),
    )
  end
end
