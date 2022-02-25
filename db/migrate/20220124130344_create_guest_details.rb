class CreateGuestDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :guest_details do |t|
      t.string :name
      t.datetime :date_of_birth
      t.integer :age
      t.string :type
      t.references :reservation, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
