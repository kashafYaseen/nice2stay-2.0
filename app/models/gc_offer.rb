class GcOffer < ApplicationRecord
  belongs_to :lodging

  translates :name, :short_description, :description
end
