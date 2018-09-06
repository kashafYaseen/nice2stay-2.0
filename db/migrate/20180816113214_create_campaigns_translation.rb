class CreateCampaignsTranslation < ActiveRecord::Migration[5.2]
 def up
    Campaign.create_translation_table!({
      title: :string,
      description: :text,
      url: :string,
      crm_urls: :string,
    },{
      migrate_data: true
    })
  end

  def down
    Campaign.drop_translation_table!
  end
end
