class RemoveRoomTypesTable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :lodgings, :room_type, foreign_key: true
    remove_reference :room_rates, :room_type, foreign_key: { on_delete: :cascade }

    drop_table :room_types do |t|
      t.string :code
      t.text :description
      t.references :parent_lodging, index: true, foreign_key: { on_delete: :cascade, to_table: :lodgings }
      t.timestamps
      t.integer :adults, default: 0
      t.integer :children, default: 0
      t.integer :infants, default: 0
      t.integer :open_gds_accommodation_id
      t.string :name
      t.integer :extra_beds, default: 0
      t.boolean :extra_beds_for_children_only, default: false
      t.integer :baths
      t.string :short_description
      t.string :images, array: true, default: []
      t.integer :num_of_accommodations, default: 1
      t.integer :minimum_adults, default: 1
      t.integer :minimum_children, default: 0
      t.integer :minimum_infants, default: 0
    end
  end
end
