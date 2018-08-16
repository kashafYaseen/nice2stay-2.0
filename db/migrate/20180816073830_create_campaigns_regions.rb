class CreateCampaignsRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns_regions do |t|
      t.references :campaign, index: true
      t.references :region, index: true
    end
    add_foreign_key :campaigns_regions, :campaigns, on_delete: :cascade
    add_foreign_key :campaigns_regions, :regions, on_delete: :cascade
  end
end
