class CreateRecentSearch < ActiveRecord::Migration[5.2]
  def change
    create_table :recent_searches do |t|
      t.date :check_in
      t.date :check_out
      t.integer :adults
      t.integer :children
      t.integer :infants
      t.bigint :searchable_id
      t.string :searchable_type
      t.references :user, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :recent_searches, %i[searchable_id searchable_type]
  end
end
