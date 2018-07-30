class CreateWishlists < ActiveRecord::Migration[5.2]
  def change
    create_table :wishlists do |t|
      t.references :lodging, index: true
      t.references :user, index: true

      t.timestamps
    end
    add_foreign_key :wishlists, :lodgings, on_delete: :cascade
    add_foreign_key :wishlists, :users, on_delete: :cascade
  end
end
