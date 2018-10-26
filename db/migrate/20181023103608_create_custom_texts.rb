class CreateCustomTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_texts do |t|
      t.integer :crm_id
      t.text :h1_text
      t.text :p_text
      t.text :meta_title
      t.text :meta_description
      t.string :redirect_url
      t.string :country
      t.string :region
      t.string :category
      t.string :experience

      t.timestamps
    end
  end
end
