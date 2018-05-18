class AddColumnsToReservations < ActiveRecord::Migration[5.1]
  def change
    add_column :reservations, :adults, :integer, default: 0
    add_column :reservations, :children, :integer, default: 0
    add_column :reservations, :infants, :integer, default: 0
  end
end
