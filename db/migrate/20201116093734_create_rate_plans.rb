class CreateRatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :rate_plans do |t|
      t.string :code
      t.string :name
      t.references :room_type, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
