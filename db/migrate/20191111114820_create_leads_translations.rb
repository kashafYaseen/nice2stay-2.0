class CreateLeadsTranslations < ActiveRecord::Migration[5.2]
  def up
    Lead.create_translation_table!({
      notes: :text,
      email_intro: :text,
    },{
      migrate_data: true
    })
  end

  def down
    Lead.drop_translation_table! migrate_data: true
  end
end
