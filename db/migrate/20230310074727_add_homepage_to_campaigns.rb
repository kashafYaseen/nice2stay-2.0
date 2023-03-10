class AddHomepageToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :homepage, :boolean, default: false
  end
end
