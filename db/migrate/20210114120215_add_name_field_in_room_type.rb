class AddNameFieldInRoomType < ActiveRecord::Migration[5.2]
  def change
    add_column :room_types, :name, :string
    RoomType.all.each do |room_type|
      room_type.name = room_type.description
      room_type.save(validate: false)
    end
  end
end
