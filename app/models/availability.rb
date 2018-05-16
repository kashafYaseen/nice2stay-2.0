class Availability < ApplicationRecord
  belongs_to :lodging
  has_many :prices

  after_commit :reindex_lodging
  validates :available_on, uniqueness: { scope: :lodging }

  def reindex_lodging
    lodging.reindex
  end
end
