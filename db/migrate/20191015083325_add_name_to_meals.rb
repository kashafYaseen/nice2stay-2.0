class AddNameToMeals < ActiveRecord::Migration[5.2]
  def change
    add_column :meals, :name, :string
  end
end
