class Price < ApplicationRecord
  belongs_to :availability
  has_one :lodging, through: :availability

  scope :of_child, -> (child_id) { joins(:availability).where('lodging_id = ?', child_id) }
  scope :search_import, -> { includes(:lodging).where.not(availability_id: nil) }

  delegate :available_on, to: :availability

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.try(:available_on),
      lodging_id: lodging.try(:id),
      adults_and_children: adults_and_children
    )
  end

  def should_index?
    availability_id.present?
  end

  def adults_and_children
    adults.max.to_i + children.max.to_i
  end
end
