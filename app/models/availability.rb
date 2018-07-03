class Availability < ApplicationRecord
  belongs_to :lodging_child
  has_one :lodging, through: :lodging_child
  has_many :prices

  after_commit :reindex_lodging
  validates :available_on, uniqueness: { scope: :lodging }

  accepts_nested_attributes_for :prices, allow_destroy: true

  scope :with_in, -> (from, to) { where('available_on > ? and available_on <= ?', from, to) }

  def reindex_lodging
    lodging.reindex
  end
end
