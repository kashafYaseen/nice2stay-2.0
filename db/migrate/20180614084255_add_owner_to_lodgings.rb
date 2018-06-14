class AddOwnerToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_reference :lodgings, :owner, index: true
    add_foreign_key :lodgings, :owners, on_delete: :cascade
  end
end
