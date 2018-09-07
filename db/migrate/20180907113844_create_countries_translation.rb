class CreateCountriesTranslation < ActiveRecord::Migration[5.2]
  def up
    Country.create_translation_table!({
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
    Country.drop_translation_table! migrate_data: true
  end
end
