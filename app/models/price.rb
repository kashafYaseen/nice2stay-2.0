class Price < ApplicationRecord
  belongs_to :availability

  delegate :lodging, :lodging_child, to: :availability

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.available_on,
      lodging_id: lodging.id,
      lodging_child_id: lodging_child.id
    )
  end
end
