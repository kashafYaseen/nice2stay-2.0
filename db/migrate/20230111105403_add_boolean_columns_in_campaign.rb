class AddBooleanColumnsInCampaign < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :footer, :boolean, default: false
    add_column :campaigns, :top_menu, :boolean, default: false
  end
end
