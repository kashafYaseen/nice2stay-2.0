class AddSecurityPayedAtToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :security_payed_at, :datetime
  end
end
