class SearchLodgingByIds
  attr_reader :lodging_ids

  def self.call(lodging_ids)
    self.new(lodging_ids).call
  end

  def initialize(lodging_ids)
    @lodging_ids = lodging_ids
  end

  def call
    Lodging.search body: { query: { bool: { filter: conditions } }, aggs: aggregation }
  end

  private
    def conditions
      conditions = []
      conditions << { terms: { id: lodging_ids } }
      conditions << { term: { published: true } }
      conditions << { term: { presentation: 'as_parent' } }
      conditions
    end

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
