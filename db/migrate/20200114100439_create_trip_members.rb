class CreateTripMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :trip_members do |t|
      t.references :user, index: true
      t.references :trip, index: true
      t.boolean :admin, default: true

      t.timestamps
    end

    add_foreign_key :trip_members, :users, on_delete: :cascade
    add_foreign_key :trip_members, :trips, on_delete: :cascade
  end
end
