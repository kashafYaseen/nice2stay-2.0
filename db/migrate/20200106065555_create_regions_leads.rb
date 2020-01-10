class CreateRegionsLeads < ActiveRecord::Migration[5.2]
  def change
    create_table :leads_regions do |t|
      t.references :lead, index: true
      t.references :region, index: true

      t.timestamps
    end
    add_foreign_key :leads_regions, :leads, on_delete: :cascade
    add_foreign_key :leads_regions, :regions, on_delete: :cascade
  end
end
