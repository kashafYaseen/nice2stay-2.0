class AddSeoPathAttributesToCustomTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :seo_path, :string
    add_column :custom_texts, :seo_path_without_locale, :string
    add_column :custom_texts, :seo_path_without_country, :string

    add_column :custom_text_translations, :seo_path, :string
    add_column :custom_text_translations, :seo_path_without_locale, :string
    add_column :custom_text_translations, :seo_path_without_country, :string
  end
end
