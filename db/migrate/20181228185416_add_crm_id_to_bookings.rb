class AddCrmIdToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :crm_id, :integer
    add_column :bookings, :created_by, :integer, default: 0
  end
end
