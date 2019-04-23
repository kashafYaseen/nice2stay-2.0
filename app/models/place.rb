class Place < ApplicationRecord
  belongs_to :country
  belongs_to :region
  belongs_to :place_category

  searchkick locations: [:location]

  extend FriendlyId
  friendly_id :name, use: :slugged

  translates :details, :description, :name, :slug

  delegate :name, to: :place_category, allow_nil: true, prefix: true

  def search_data
    attributes.merge(
      location: { lat: latitude, lon: longitude },
    )
  end

  def feature
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [longitude, latitude]
      },
      properties: {
        id: id,
        title: name,
        description: description,
        image: images.try(:first),
        'marker-color': '#7D3C98',
        'marker-size': 'small',
      }
    }
  end

  def distance_from lodging
    Geocoder::Calculations.distance_between(
      [lodging.longitude, lodging.latitude],
      [longitude, latitude]
    ).round(2)
  end
end
