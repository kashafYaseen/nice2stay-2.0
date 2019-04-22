class Place < ApplicationRecord
  belongs_to :country
  belongs_to :region
  belongs_to :place_category

  searchkick locations: [:location]

  extend FriendlyId
  friendly_id :name, use: :slugged

  translates :details, :description, :name, :slug

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
end
