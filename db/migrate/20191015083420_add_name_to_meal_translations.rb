class AddNameToMealTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :meal_translations, :name, :string
  end
end
