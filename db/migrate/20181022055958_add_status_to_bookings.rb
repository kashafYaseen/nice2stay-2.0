class AddStatusToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :booking_status, :integer, default: 0
  end
end
