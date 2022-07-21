class CountTotalLodgings
  attr_reader :only_parent

  def self.call(only_parent=false)
    self.new(only_parent).call
  end

  def initialize(only_parent=false)
    @only_parent = only_parent
  end

  def call
    return Lodging.search body: { query: { bool: { filter: { terms: { presentation: ['as_child', 'as_standalone'] } } } }, aggs: aggregation } unless only_parent
    Lodging.search body: { query: { bool: { filter: { terms: { presentation: ['as_parent', 'as_standalone'] } } } }, aggs: aggregation }
  end

  private
    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        countries: { terms: { field: :country_id } },
        amenities: { terms: { field: :amenities_ids, size: Amenity.count } },
        experiences: { terms: { field: :experiences_ids, size: Experience.count } },
        lodging_categories: { terms: { field: :lodging_category_id } },
        discounts: { terms: { field: :discounts } },
        checked: { terms: { field: :checked } },
        realtime_availability: { terms: { field: :realtime_availability } },
        free_cancelation: { terms: { field: :free_cancelation } },
      }
    end
end
