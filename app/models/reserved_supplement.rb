class ReservedSupplement < ApplicationRecord
  belongs_to :reservation

  before_create :cumulative_price
  attr_accessor :maximum_number

  enum supplement_type: {
    optional: 0,
    mandatory: 1
  }

  enum rate_type: {
    'Per Piece': 0,
    'Per Piece Per Day': 1,
    'Per Piece Per Night': 2,
    'Per Person': 3,
    'Per Person Per Day': 4,
    'Per Person Per Night': 5,
    'Per Stay': 6,
    'Per Stay Per Day': 7,
    'Per Stay Per Night': 8,
  }

  def cumulative_price
    # Temporary fix to calculate price
    # build params from reservation attributes and convert keys to symbols
    # make two virtual attributes maximum_number and quantity
    # maximum number will always be greater than quantity send all these attributes to CalculateSupplementsPrices
    params = reservation.attributes.deep_symbolize_keys
    self.maximum_number = self.quantity.to_i + 1

    supplement_price = CalculateSupplementsPrices.call(
      supplement: self,
      params: params.merge(
        selected_adults: params[:adults].to_i,
        selected_children: params[:children].to_i,
        quantity: quantity.to_i
      )
    )

    # you can create total as a virtual attribute instead of column
    self.total = supplement_price.dig(:calculated_price)
  end
end
