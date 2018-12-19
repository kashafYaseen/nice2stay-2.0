class AddPopularToCustomTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :popular, :boolean, default: false
  end
end
