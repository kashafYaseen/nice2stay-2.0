class CreateAmenityCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :amenity_categories do |t|
      t.string :name
      t.integer :crm_id

      t.timestamps
    end
  end
end
