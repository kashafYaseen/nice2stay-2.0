class AddCatrgoryIdToAmenities < ActiveRecord::Migration[5.2]
  def change
    add_reference :amenities, :amenity_category, index: true
    add_foreign_key :amenities, :amenity_categories, on_delete: :cascade
  end
end
