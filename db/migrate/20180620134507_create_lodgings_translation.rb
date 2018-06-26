class CreateLodgingsTranslation < ActiveRecord::Migration[5.2]
 def up
    Lodging.create_translation_table!({
      title: :string,
      subtitle: :string,
      description: :text
    },{
      migrate_data: true
    })
  end

  def down
    Lodging.drop_translation_table! migrate_data: true
  end
end
