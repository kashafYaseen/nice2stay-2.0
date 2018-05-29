class CreateRules < ActiveRecord::Migration[5.1]
  def change
    create_table :rules do |t|
      t.references :lodging, index: true
      t.date :start_date
      t.date :end_date
      t.integer :days_multiplier
      t.string :check_in_days

      t.timestamps
    end
    add_foreign_key :rules, :lodgings, on_delete: :cascade
  end
end
