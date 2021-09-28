class CreateSupplements < ActiveRecord::Migration[5.2]
  def change
    create_table :supplements do |t|
      t.string :name
      t.text :description
      t.integer :supplement_type, default: 0
      t.integer :rate_type
      t.decimal :rate
      t.decimal :child_rate
      t.integer :maximum_number, default: 0
      t.boolean :published, default: false
      t.boolean :valid_permanent, default: false
      t.datetime :valid_from
      t.datetime :valid_till
      t.string :valid_on_arrival_days, array: true, default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      t.string :valid_on_departure_days, array: true, default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      t.string :valid_on_stay_days, array: true, default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      t.string :possible_days_with_date_selection, array: true, default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      t.boolean :arrival_possible_with_date_selection, default: true
      t.boolean :departure_possible_with_date_selection, default: true
      t.bigint :crm_id
      t.references :lodging, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
