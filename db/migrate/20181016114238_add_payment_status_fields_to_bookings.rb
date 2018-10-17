class AddPaymentStatusFieldsToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :pre_payed_at, :datetime
    add_column :bookings, :final_payed_at, :datetime
  end
end
