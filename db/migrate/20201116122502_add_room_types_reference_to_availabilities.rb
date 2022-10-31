class AddRoomTypesReferenceToAvailabilities < ActiveRecord::Migration[5.2]
  def change
    add_reference :availabilities, :room_type, { on_delete: :cascade }
  end
end
