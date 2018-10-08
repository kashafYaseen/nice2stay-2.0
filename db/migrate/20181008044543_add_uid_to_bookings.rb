class AddUidToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :uid, :uuid
  end
end
