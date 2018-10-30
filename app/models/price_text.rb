class PriceText < ApplicationRecord
  belongs_to :lodging
  translates :season_text, :including_text, :pay_text, :deposit_text, :options_text, :particularities_text, :payment_terms_text
end
