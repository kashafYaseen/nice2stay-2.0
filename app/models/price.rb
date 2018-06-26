class Price < ApplicationRecord
  belongs_to :availability

  delegate :lodging, to: :availability

  scope :with_in, -> (from, to) { joins(:availability).where('availabilities.available_on > ? and availabilities.available_on <= ?', from, to) }

  searchkick

  def search_data
    attributes.merge(
      available_on: availability.available_on,
      lodging_id: lodging.id
    )
  end
end
