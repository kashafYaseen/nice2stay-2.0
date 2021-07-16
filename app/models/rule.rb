class Rule < ApplicationRecord
  belongs_to :lodging
  belongs_to :rate_plan, optional: true

  DAY_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']

  scope :active_flexible, -> (check_in, check_out) { where("((start_date is :nil and end_date is :nil) or (start_date <= :start_date and end_date >= :end_date) or (start_date <= :start_date and end_date >= :end_date)) AND (checkin_day = :checkin_day or checkin_day = 'any')", nil: nil, start_date: check_in, end_date: check_out, checkin_day: check_in.strftime("%A").downcase) }
  scope :active, -> (check_in, check_out) { where("(start_date is :nil and end_date is :nil) or (start_date <= :start_date and end_date >= :end_date) or (start_date <= :start_date and end_date >= :end_date) or ((start_date <= :start_date and end_date >= :start_date) or (start_date <= :end_date and end_date >= :end_date))", nil: nil, start_date: check_in, end_date: check_out) }
  scope :with_published_lodgings, -> { joins(:lodging).where("lodgings.published = true") }
  scope :with_published_room_rates, -> { joins(rate_plan: { room_rates: :child_lodging }).where("room_rates.publish = true AND lodgings.published = true").distinct }

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

  enum open_gds_restriction_type: {
    disabled: 0,
    till: 1,
    from: 2
  }, _prefix: :restriction_type

  def search_data
    attributes.merge(
      dates: (start_date..end_date).map(&:to_s), check_in_day: lodging.check_in_day,
      minimum_stay: (minimum_stay || 7),
      rate_enabled: rate_plan.try(:rate_enabled)
    )
  end

  def max_stay
    minimum_stay.map(&:to_i).max
  end

  def min_stay
    minimum_stay.map(&:to_i).min
  end
end
