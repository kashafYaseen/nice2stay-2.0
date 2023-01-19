class AddRoomTypesToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_reference :lodgings, :room_type, index: true
    # add_foreign_key :lodgings, :room_types
  end
end
