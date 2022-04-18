class AddDeleteCascadeToGuestDetails < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :guest_details, :reservations
    add_foreign_key :guest_details, :reservations, on_delete: :cascade
  end

  def down
    remove_foreign_key :guest_details, :reservations
    add_foreign_key :guest_details, :reservations
  end
end
