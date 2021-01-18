class Price < ApplicationRecord
  belongs_to :availability
  has_one :lodging, through: :availability
  has_one :room_type, through: :availability
  has_one :room_rate, through: :availability
  has_one :rate_plan, through: :availability

  scope :of_child, -> (child_id) { joins(:availability).where('lodging_id = ?', child_id) }
  scope :search_import, -> { includes(:lodging).where.not(availability_id: nil) }

  delegate :available_on, to: :availability

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

  enum open_gds_single_rate_type: {
    fixed_price: 0,
    percentage: 1
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
end
