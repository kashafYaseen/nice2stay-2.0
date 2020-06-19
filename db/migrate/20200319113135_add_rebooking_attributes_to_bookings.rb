class AddRebookingAttributesToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :rebooked, :boolean, default: false
    add_column :bookings, :rebooking_approved, :boolean, default: false
  end
end
