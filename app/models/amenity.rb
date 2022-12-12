class Amenity < ApplicationRecord
  belongs_to :amenity_category
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_amenities'

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :slug
  globalize_accessors

  before_save :name_downcase

  scope :hot, -> { where(hot: true).distinct }
  scope :regular, -> { where(hot: false).distinct }

  delegate :name, to: :amenity_category, prefix: true, allow_nil: true

  def name_downcase
    self.name.downcase!
  end

  def amenities_count_for lodgings
    buckets = lodgings.aggregations['amenities']['buckets']
    count = 0
    buckets.each do |bucket|
      count = bucket['doc_count'] if bucket['key'] == self.id
    end if buckets.present?
    count
  end

  def translated_slugs
    translations.pluck(:slug)
  end
end
