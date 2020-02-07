class CreateGcOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :gc_offers do |t|
      t.string :name
      t.string :offer_id
      t.text :short_description
      t.text :description
      t.references :lodging, index: true

      t.timestamps null: false
    end

    add_foreign_key :gc_offers, :lodgings, on_delete: :cascade
  end
end
