class AddExtraBedsToRoomTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :room_types, :extra_beds, :integer, default: 0
    add_column :room_types, :extra_beds_for_children_only, :boolean, default: false
  end
end
