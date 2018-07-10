class AddCrmAttributesToLodgingTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :lodging_translations, :meta_desc, :text
    add_column :lodging_translations, :slug, :string
    add_column :lodging_translations, :h1, :string
    add_column :lodging_translations, :h2, :string
    add_column :lodging_translations, :h3, :string
    add_column :lodging_translations, :highlight_1, :string
    add_column :lodging_translations, :highlight_2, :string
    add_column :lodging_translations, :highlight_3, :string
    add_column :lodging_translations, :summary, :text
    add_column :lodging_translations, :short_desc, :text
    add_column :lodging_translations, :location_description, :text
  end
end
