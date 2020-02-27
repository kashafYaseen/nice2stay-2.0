class AddCrmIdToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :crm_id, :integer
    add_index :lodgings, :crm_id, unique: true
  end
end
