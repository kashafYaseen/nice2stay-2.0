class CreateCustomTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_texts do |t|
      t.integer :crm_id
      t.text :h1_text
      t.text :p_text
      t.text :meta_title
      t.text :meta_description
      t.string :category

      t.timestamps
    end
  end
end
