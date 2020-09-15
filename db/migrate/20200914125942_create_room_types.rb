class CreateRoomTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :room_types do |t|
      t.string :code
      t.string :description
      t.references :parent_lodging, index: true

      t.timestamps
    end

    add_foreign_key :room_types, :lodgings, on_delete: :cascade, column: :parent_lodging_id
  end
end
