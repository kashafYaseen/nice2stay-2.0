class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.string   :name
      t.string   :address
      t.text     :details
      t.text     :description
      t.string   :publish
      t.string   :slug
      t.boolean  :spotlight
      t.boolean  :header_dropdown
      t.text     :short_desc
      t.string   :short_desc_nav
      t.string   :images, array: true, default: []
      t.float    :latitude
      t.float    :longitude

      t.references :country, index: true
      t.references :region, index: true
      t.references :place_category, index: true

      t.timestamps
    end
    add_foreign_key :places, :countries, on_delete: :cascade
    add_foreign_key :places, :regions, on_delete: :cascade
  end
end
