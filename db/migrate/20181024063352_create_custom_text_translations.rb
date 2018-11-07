class CreateCustomTextTranslations < ActiveRecord::Migration[5.2]
  def up
    CustomText.create_translation_table!({
      h1_text: :text,
      p_text: :text,
      meta_title: :text,
      meta_description: :text,
      category: :string,
    },{
      migrate_data: true
    })
  end

  def down
    CustomText.drop_translation_table!
  end
end
