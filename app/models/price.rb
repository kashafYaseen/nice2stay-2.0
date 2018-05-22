class Price < ApplicationRecord
  belongs_to :availability

  delegate :lodging, to: :availability
end
