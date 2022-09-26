class AddFieldsToRoomTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :room_types, :adults, :integer, default: 0
    add_column :room_types, :children, :integer, default: 0
    add_column :room_types, :infants, :integer, default: 0
  end
end
