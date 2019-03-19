class AddShowPageToCustomTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :show_page, :boolean, default: false
  end
end
