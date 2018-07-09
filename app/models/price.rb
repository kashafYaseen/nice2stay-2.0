class Price < ApplicationRecord
  belongs_to :availability
  has_one :lodging, through: :availability
  has_one :lodging_child, through: :availability

  scope :of_child, -> (child_id) { joins(:availability).where('lodging_child_id = ?', child_id) }

  delegate :available_on, to: :availability

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.available_on,
      lodging_id: lodging.id,
      lodging_child_id: lodging_child.id
    )
  end
end
