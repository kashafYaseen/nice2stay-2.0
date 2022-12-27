class LodgingCategory < ApplicationRecord
  has_many :lodgings

  translates :name
  globalize_accessors

  def lodging_category_count_for lodgings
    buckets = lodgings.aggregations['lodging_categories']['buckets']
    count = 0
    buckets.each do |bucket|
      count = bucket['doc_count'] if bucket['key'] == self.id
    end if buckets.present?
    count
  end

  def translated_names
    translations.pluck(:name)
  end
end
