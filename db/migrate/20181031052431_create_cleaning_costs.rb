class CreateCleaningCosts < ActiveRecord::Migration[5.2]
  def change
    create_table :cleaning_costs do |t|
      t.string :name
      t.float :fixed_price, default: 0.0
      t.float :price_per_day, default: 0.0
      t.integer :guests
      t.integer :crm_id
      t.boolean :manage_by
      t.references :lodging, index: true

      t.timestamps
    end
    add_foreign_key :cleaning_costs, :lodgings, on_delete: :cascade
  end
end
