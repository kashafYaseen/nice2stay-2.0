class CreateChildRates < ActiveRecord::Migration[5.2]
  def change
    create_table :child_rates do |t|
      t.integer :children
      t.decimal :rate
      t.integer :rate_type
      t.references :rate_plan, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
