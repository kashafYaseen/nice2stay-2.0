class AddPageTranslations < ActiveRecord::Migration[5.2]
  def up
    Page.create_translation_table!({
      title: :string,
      meta_title: :string,
      short_desc: :text,
      content: :text,
      category: :string,
      slug: :string,
    }, {
      migrate_data: true
    })
  end

  def down
    Page.drop_translation_table! migrate_data: true
  end
end
