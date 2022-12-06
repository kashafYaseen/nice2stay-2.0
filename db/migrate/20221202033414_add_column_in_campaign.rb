class AddColumnInCampaign < ActiveRecord::Migration[5.2]
  def change
    add_column :campaigns, :region_id, :integer
    add_column :campaigns, :country_id, :integer
    add_column :campaigns, :min_price, :float
    add_column :campaigns, :max_price, :float
    add_column :campaigns, :from, :datetime
    add_column :campaigns, :to, :datetime
    add_column :campaigns, :category, :text
  end
end
