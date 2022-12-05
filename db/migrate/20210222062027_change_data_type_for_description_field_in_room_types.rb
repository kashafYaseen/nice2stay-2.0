class ChangeDataTypeForDescriptionFieldInRoomTypes < ActiveRecord::Migration[5.2]
  def up
    change_column :room_types, :description, :text
  end

  def down
    change_column :room_types, :description, :string
  end
end
