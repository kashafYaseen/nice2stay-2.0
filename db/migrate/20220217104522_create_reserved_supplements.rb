class CreateReservedSupplements < ActiveRecord::Migration[5.2]
  def change
    create_table :reserved_supplements do |t|
      t.string :name
      t.text :description
      t.integer :supplement_type, default: 0
      t.integer :rate_type, default: '0.0'
      t.decimal :rate, default: '0.0'
      t.decimal :child_rate, default: '0.0'
      t.decimal :total, default: '0.0'
      t.references :reservation, index: true, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
