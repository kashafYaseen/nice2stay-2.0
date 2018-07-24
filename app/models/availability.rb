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

  def self.check_out_only!(check_in)
    days = where(available_on: [check_in -1.day, check_in]).order(available_on: :desc)
    return days.take.update_columns(check_out_only: true) if days.size == 2
    days.take.try(:delete)
  end
end
