class Voucher < ApplicationRecord
  belongs_to :receiver, class_name: 'User'
end
