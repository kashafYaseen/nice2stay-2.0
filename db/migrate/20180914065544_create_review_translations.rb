class CreateReviewTranslations < ActiveRecord::Migration[5.2]
  def up
    Review.create_translation_table!({
      title: :string,
      suggetion: :text,
      description: :text
    },{
      migrate_data: true
    })
  end

  def down
    Review.drop_translation_table! migrate_data: true
  end
end
