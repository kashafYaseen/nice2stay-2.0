class AddCrmIdToCountry < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :crm_id, :integer
    add_index :countries, :crm_id, unique: true
  end
end
