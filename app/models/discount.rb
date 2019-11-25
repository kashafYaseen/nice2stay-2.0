class Discount < ApplicationRecord
  belongs_to :lodging
  searchkick

  scope :active, -> { where("valid_to >= ? and publish = ?", Date.today, true) }

  delegate :name, to: :lodging, prefix: true
  attr_accessor :total_nights

  enum discount_type: {
    percentage: "percentage",
    incentive: "incentive",
    amount: "amount",
  }

  def search_data
    attributes.merge(
      dates: (start_date..end_date).map(&:to_s),
    )
  end

  def set_nights dates
    self.total_nights = (search_data[:dates] & dates).count
  end

  def invoice_features
    { value: value, discount_type: discount_type, total_nights: total_nights }
  end
end
