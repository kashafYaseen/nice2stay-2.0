class CreatePrices < ActiveRecord::Migration[5.1]
  def change
    create_table :prices do |t|
      t.float :amount, default: 0
      t.integer :adults, default: 1
      t.integer :children, default: 1
      t.integer :infants, default: 1
      t.references :availability, index: true

      t.timestamps
    end
    add_foreign_key :prices, :availabilities, on_delete: :cascade
  end
end
