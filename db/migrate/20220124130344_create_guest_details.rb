class CreateGuestDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :guest_details do |t|
      t.string :name
      t.datetime :date_of_birth
      t.integer :age
      t.string :type
      t.references :reservation, index: true

      t.timestamps
    end
  end
end
