class Availability < ApplicationRecord
  belongs_to :lodging
  has_many :prices

  after_commit :reindex_lodging
  validates :available_on, uniqueness: { scope: :lodging }

  accepts_nested_attributes_for :prices, allow_destroy: true

  def reindex_lodging
    lodging.reindex
  end
end
