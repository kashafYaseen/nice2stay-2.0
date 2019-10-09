class CreateOfferLodgings < ActiveRecord::Migration[5.2]
  def change
    create_table :offer_lodgings do |t|
      t.references :offer, index: true
      t.references :lodging, index: true
      t.text :notes

      t.timestamps
    end
    add_foreign_key :offer_lodgings, :offers, on_delete: :cascade
    add_foreign_key :offer_lodgings, :lodgings, on_delete: :cascade
  end
end
