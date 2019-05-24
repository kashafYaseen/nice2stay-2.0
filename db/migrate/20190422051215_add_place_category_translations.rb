class AddPlaceCategoryTranslations < ActiveRecord::Migration[5.2]
  def up
    PlaceCategory.create_translation_table!({
      name: :string,
      slug: :string,
    }, {
      migrate_data: true
    })
  end

  def down
    PlaceCategory.drop_translation_table! migrate_data: true
  end
end
