class UpdateLodgingRelations < ActiveRecord::Migration[5.2]
  def change
    remove_reference :reservations, :lodging, foreign_key: true
    remove_reference :availabilities, :lodging, foreign_key: true

    add_reference :availabilities, :lodging_child, index: true
    add_reference :reservations, :lodging_child, index: true
    add_foreign_key :availabilities, :lodging_children
    add_foreign_key :reservations, :lodging_children
  end
end
