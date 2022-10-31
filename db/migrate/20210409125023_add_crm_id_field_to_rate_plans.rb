class AddCrmIdFieldToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :crm_id, :bigint
  end
end
