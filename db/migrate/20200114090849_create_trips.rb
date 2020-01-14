class CreateTrips < ActiveRecord::Migration[5.2]
  def change
    create_table :trips do |t|
      t.string :name
      t.integer :adults, default: 1
      t.integer :children, default: 0
      t.float :budget, default: 0
      t.date :check_in
      t.date :check_out

      t.timestamps
    end

    add_reference :wishlists, :trip, index: true
    add_foreign_key :wishlists, :trips, on_delete: :cascade
  end
end
