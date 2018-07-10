class UpdateForeignKeysToCascadeDelete < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :availabilities, :lodging_children
    add_foreign_key :availabilities, :lodging_children, on_delete: :cascade

    remove_foreign_key :reservations, :lodging_children
    add_foreign_key :reservations, :lodging_children, on_delete: :cascade

    remove_foreign_key :reviews, :lodgings
    add_foreign_key :reviews, :lodgings, on_delete: :cascade

    remove_foreign_key :reviews, :users
    add_foreign_key :reviews, :users, on_delete: :cascade

    remove_foreign_key :reservations, :users
    add_foreign_key :reservations, :users, on_delete: :cascade

    remove_foreign_key :specifications, :lodgings
    add_foreign_key :specifications, :lodgings, on_delete: :cascade
  end
end
