class AddColumnsInReservation < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :commission, :float, default: 0
    add_column :bookings, :owner_name, :float, default: 0
  end
end
