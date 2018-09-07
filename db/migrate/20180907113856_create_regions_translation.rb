class CreateRegionsTranslation < ActiveRecord::Migration[5.2]
  def up
    Region.create_translation_table!({
      name: :string,
      content: :text,
      slug: :string,
      title: :string,
      meta_title: :string,
    },{
      migrate_data: true
    })
  end

  def down
    Region.drop_translation_table! migrate_data: true
  end
end
