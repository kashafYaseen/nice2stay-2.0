class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.string      :name
      t.references  :country, index: true
      t.text        :content
      t.string      :slug
      t.string      :title
      t.string      :meta_title
      t.text        :villas_desc
      t.text        :apartment_desc
      t.text        :bb_desc
      t.text        :short_desc

      t.timestamps
    end
    add_foreign_key :regions, :countries, on_delete: :cascade
  end
end
