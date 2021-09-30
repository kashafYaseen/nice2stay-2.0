class CreateSupplementTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :supplement_translations do |t|
      t.string :locale
      t.string :name
      t.text :description
      t.bigint :crm_id
      t.references :supplement, index: true, foreign_key: { on_delete: :cascade }

      t.timestamps null: false
    end
  end
end
