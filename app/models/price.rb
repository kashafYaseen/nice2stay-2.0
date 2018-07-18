class Price < ApplicationRecord
  belongs_to :availability
  has_one :lodging, through: :availability
  has_one :lodging_child, through: :availability

  scope :of_child, -> (child_id) { joins(:availability).where('lodging_child_id = ?', child_id) }
  scope :search_import, -> { includes(:lodging, :lodging_child) }

  delegate :available_on, to: :availability

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.available_on,
      lodging_id: lodging.id,
      lodging_child_id: lodging_child.id,
      adults_and_children: adults_and_children
    )
  end

  def adults_and_children
    adults.max.to_i + children.max.to_i
  end
end
