class AddGcRoomsToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :gc_rooms, :string, array: true, default: []
  end
end
