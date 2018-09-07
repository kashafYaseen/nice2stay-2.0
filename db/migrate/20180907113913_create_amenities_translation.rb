class CreateAmenitiesTranslation < ActiveRecord::Migration[5.2]
  def up
    Amenity.create_translation_table!({
      name: :string,
      slug: :string,
    },{
      migrate_data: true
    })
  end

  def down
    Amenity.drop_translation_table! migrate_data: true
  end
end
