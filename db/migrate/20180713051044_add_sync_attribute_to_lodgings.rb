class AddSyncAttributeToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :crm_synced_at, :datetime
  end
end
