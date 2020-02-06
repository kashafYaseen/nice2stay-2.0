class CreateGcOffersTranslations < ActiveRecord::Migration[5.2]
  def up
    GcOffer.create_translation_table!({
      name: :string,
      short_description: :text,
      description: :text
    },{
      migrate_data: true
    })
  end

  def down
    GcOffer.drop_translation_table! migrate_data: true
  end
end
