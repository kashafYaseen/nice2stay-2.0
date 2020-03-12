class CountTotalLodgings
  def self.call()
    self.new().call
  end

  def initialize()
  end

  def call
    Lodging.search body: { query: { bool: { filter: { terms: { presentation: ['as_child', 'as_standalone'] } } } }, aggs: aggregation }
  end

  private
    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        countries: { terms: { field: :country_id } },
        amenities: { terms: { field: :amenities_ids, size: Amenity.count } },
        experiences: { terms: { field: :experiences_ids, size: Experience.count } },
        discounts: { terms: { field: :discounts } },
        checked: { terms: { field: :checked } },
        realtime_availability: { terms: { field: :realtime_availability } },
        free_cancelation: { terms: { field: :free_cancelation } },
      }
    end
end
