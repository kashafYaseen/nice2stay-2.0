class AddCanceledToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :canceled, :boolean, default: false
    add_column :reservations, :canceled, :boolean, default: false
  end
end
