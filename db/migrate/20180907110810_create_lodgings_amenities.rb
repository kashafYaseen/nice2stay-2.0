class CreateLodgingsAmenities < ActiveRecord::Migration[5.2]
  def change
    create_table :lodgings_amenities do |t|
      t.references :lodging, index: true
      t.references :amenity, index: true
    end
    add_foreign_key :lodgings_amenities, :lodgings, on_delete: :cascade
    add_foreign_key :lodgings_amenities, :amenities, on_delete: :cascade
  end
end
