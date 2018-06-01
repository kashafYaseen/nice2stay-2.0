class CreateDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :discounts do |t|
      t.references :lodging, index: true
      t.date :start_date
      t.date :end_date
      t.integer :reservation_days
      t.float :discount_percentage

      t.timestamps
    end
    add_foreign_key :discounts, :lodgings, on_delete: :cascade
  end
end
