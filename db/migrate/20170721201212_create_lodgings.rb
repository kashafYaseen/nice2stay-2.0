class CreateLodgings < ActiveRecord::Migration[5.1]
  def change
    create_table :lodgings do |t|
      t.string :street
      t.string :city
      t.string :zip
      t.string :state
      t.integer :beds
      t.integer :baths
      t.float :sq__ft
      t.datetime :sale_date
      t.integer :price
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
