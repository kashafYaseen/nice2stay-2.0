class CreatePriceTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :price_texts do |t|
      t.text :season_text
      t.text :including_text
      t.text :pay_text
      t.text :deposit_text
      t.text :options_text
      t.text :particularities_text
      t.text :payment_terms_text
      t.references :lodging, index: true

      t.timestamps
    end
    add_foreign_key :price_texts, :lodgings, on_delete: :cascade
  end
end
