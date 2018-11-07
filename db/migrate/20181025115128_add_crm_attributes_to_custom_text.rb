class AddCrmAttributesToCustomText < ActiveRecord::Migration[5.2]
  def change
    add_reference :custom_texts, :country, index: true
    add_reference :custom_texts, :region, index: true
    add_reference :custom_texts, :experience, index: true
    add_foreign_key :custom_texts, :countries, on_delete: :cascade
    add_foreign_key :custom_texts, :regions, on_delete: :cascade
    add_foreign_key :custom_texts, :experiences, on_delete: :cascade

    add_column :custom_texts, :homepage, :boolean, default: false
    add_column :custom_texts, :country_page, :boolean, default: false
    add_column :custom_texts, :region_page, :boolean, default: false
    add_column :custom_texts, :navigation_popular, :boolean, default: false
    add_column :custom_texts, :navigation_country, :boolean, default: false
    add_column :custom_texts, :image, :string
  end
end
