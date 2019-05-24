class CreatePlaceCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :place_categories do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
    add_foreign_key :places, :place_categories, on_delete: :cascade
  end
end
