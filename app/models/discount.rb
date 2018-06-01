class Discount < ApplicationRecord
  belongs_to :lodging

  scope :active, -> { where("(start_date is ? and end_date is ?) or (start_date <= ? and end_date > ?)", nil, nil, Date.today, Date.today) }
end
