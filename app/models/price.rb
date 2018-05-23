class Price < ApplicationRecord
  belongs_to :availability

  delegate :lodging, to: :availability

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.available_on,
      lodging_id: lodging.id
    )
  end
end
