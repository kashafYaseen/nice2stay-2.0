class AddCrmIdToRegion < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :crm_id, :integer
    add_index :regions, :crm_id, unique: true
  end
end
