class AddCrmAttributesToCustomText < ActiveRecord::Migration[5.2]
  def change
    remove_column :custom_texts, :redirect_url, :string
    remove_column :custom_text_translations, :redirect_url, :string
    add_column :custom_texts, :homepage, :boolean, default: false
    add_column :custom_texts, :country_page, :boolean, default: false
    add_column :custom_texts, :region_page, :boolean, default: false
    add_column :custom_texts, :navigation_popular, :boolean, default: false
    add_column :custom_texts, :navigation_country, :boolean, default: false
    add_column :custom_texts, :image, :string
  end
end
