class AddRoomsToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :rooms, :integer, default: 1
  end
end
