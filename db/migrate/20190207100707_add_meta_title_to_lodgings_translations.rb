class AddMetaTitleToLodgingsTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :lodging_translations, :meta_title, :string
  end
end
