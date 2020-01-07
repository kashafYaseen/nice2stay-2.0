class AmenityCategoryTranslations < ActiveRecord::Migration[5.2]
  def up
    AmenityCategory.create_translation_table!({
      name: :string,
    }, {
      migrate_data: true
    })
  end

  def down
    AmenityCategory.drop_translation_table! migrate_data: true
  end
end
