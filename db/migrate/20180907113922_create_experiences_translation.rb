class CreateExperiencesTranslation < ActiveRecord::Migration[5.2]
  def up
    Experience.create_translation_table!({
      name: :string,
      slug: :string,
    },{
      migrate_data: true
    })
  end

  def down
    Experience.drop_translation_table! migrate_data: true
  end
end
