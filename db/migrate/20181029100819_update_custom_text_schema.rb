class UpdateCustomTextSchema < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :menu_title, :string
    add_column :custom_text_translations, :menu_title, :string

    remove_column :custom_texts, :seo_path_without_locale, :string
    remove_column :custom_texts, :seo_path_without_country, :string
    remove_column :custom_text_translations, :seo_path_without_locale, :string
    remove_column :custom_text_translations, :seo_path_without_country, :string
  end
end
