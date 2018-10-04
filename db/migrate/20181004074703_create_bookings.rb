class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.references :user, index: true
      t.boolean :confirmed, default: false
      t.boolean :in_cart, default: true

      t.timestamps
    end
    add_foreign_key :bookings, :users, on_delete: :cascade
  end
end
