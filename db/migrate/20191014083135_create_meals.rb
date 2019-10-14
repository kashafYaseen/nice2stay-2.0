class CreateMeals < ActiveRecord::Migration[5.2]
  def change
    create_table :meals do |t|
      t.integer :gc_meal_id
      t.text :description

      t.timestamps
    end
  end
end
