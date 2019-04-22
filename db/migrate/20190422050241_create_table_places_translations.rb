class CreateTablePlacesTranslations < ActiveRecord::Migration[5.2]
  def up
    Place.create_translation_table!({
      details: :text,
      description: :text,
      name: :string,
      slug: :string,
    }, {
      migrate_data: true
    })
  end

  def down
    Place.drop_translation_table! migrate_data: true
  end
end
