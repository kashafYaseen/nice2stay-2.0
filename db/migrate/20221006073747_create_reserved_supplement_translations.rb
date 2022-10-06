class CreateReservedSupplementTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :reserved_supplement_translations do |t|
      t.string :locale
      t.string :name
      t.text :description
      t.references :reserved_supplement, index: {name: :reserved_supplement_translation_index}, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
