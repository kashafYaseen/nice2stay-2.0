class AddRoomTypeFieldsToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :rr_room_type_code, :string
    add_column :lodgings, :rr_room_type_description, :string
  end
end
