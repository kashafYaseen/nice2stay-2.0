class AddInspirationToCustomTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_texts, :inspiration, :boolean, default: false
  end
end
