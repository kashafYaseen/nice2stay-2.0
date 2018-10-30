class CreatePriceTextTranslations < ActiveRecord::Migration[5.2]
  def up
    PriceText.create_translation_table!({
      season_text: :text,
      including_text: :text,
      pay_text: :text,
      deposit_text: :text,
      options_text: :text,
      particularities_text: :text,
      payment_terms_text: :text,
    },{
      migrate_data: true
    })
  end

  def down
    PriceText.drop_translation_table!
  end
end
