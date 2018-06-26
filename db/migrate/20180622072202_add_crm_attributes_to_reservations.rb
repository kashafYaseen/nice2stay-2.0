class AddCrmAttributesToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :total_price, :float, default: 0.0
    add_column :reservations, :rent, :float, default: 0.0
    add_column :reservations, :discount, :float, default: 0.0
    add_column :reservations, :cleaning_cost, :float, default: 0.0
    add_column :reservations, :booking_status, :integer, default: 0
    add_column :reservations, :request_status, :integer, default: 0
  end
end
