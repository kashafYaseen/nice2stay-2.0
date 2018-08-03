class UpdateLodgingChildSchema < ActiveRecord::Migration[5.2]
  def change
    remove_reference :reservations, :lodging_child, index: true
    remove_reference :availabilities, :lodging_child, index: true

    add_reference :availabilities, :lodging, index: true
    add_reference :reservations, :lodging, index: true
    add_foreign_key :availabilities, :lodgings, on_delete: :cascade
    add_foreign_key :reservations, :lodgings, on_delete: :cascade
  end
end
