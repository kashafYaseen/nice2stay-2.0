class Price < ApplicationRecord
  belongs_to :availability
  has_one :lodging, through: :availability
  has_one :room_type, through: :availability
  has_one :room_rate, through: :availability
  has_one :rate_plan, through: :availability

  scope :of_child, -> (child_id) { joins(:availability).where('lodging_id = ?', child_id) }
  scope :search_import, -> { includes(:lodging).where.not(availability_id: nil) }

  delegate :available_on, to: :availability, allow_nil: true

  searchkick

  enum checkin: {
    any: 0,
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7
  }

  def search_data
    attributes.merge(
      available_on: availability.try(:available_on),
      lodging_id: lodging.try(:id),
      adults_and_children: adults_and_children,
      room_rate_id: room_rate.try(:id)
    )
  end

  def should_index?
    availability_id.present?
  end

  def adults_and_children
    adults.max.to_i + children.max.to_i
  end

  def has_adults? selected_adults
    adults.include?(selected_adults.to_s) || adults.include?('999')
  end

  def has_children? selected_children
    children.include?(selected_children.to_s) || children.include?('999')
  end

  def has_minimum_stay? selected_nights
    minimum_stay.include?(selected_nights.to_s) || minimum_stay.include?('999')
  end
end
