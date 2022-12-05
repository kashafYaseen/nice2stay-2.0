class CreateLodgingPlaceCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :lodging_place_categories do |t|
      t.references :lodging, index: true
      t.references :place_category, index: true
    end
    add_foreign_key :lodging_place_categories, :lodgings, on_delete: :cascade
    add_foreign_key :lodging_place_categories, :place_categories, on_delete: :cascade
  end
end
