class CreateMealTranslations < ActiveRecord::Migration[5.2]
 def up
    Meal.create_translation_table!({
      description: :text
    },{
      migrate_data: true
    })
  end

  def down
    Meal.drop_translation_table! migrate_data: true
  end
end
