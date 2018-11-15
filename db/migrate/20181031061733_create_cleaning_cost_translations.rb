class CreateCleaningCostTranslations < ActiveRecord::Migration[5.2]
 def up
    CleaningCost.create_translation_table!({
      name: :string,
    },{
      migrate_data: true
    })
  end

  def down
    CleaningCost.drop_translation_table! migrate_data: true
  end
end
