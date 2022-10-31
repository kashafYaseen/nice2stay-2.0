class AddSingleRateTypeFieldToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :open_gds_single_rate_type, :integer
  end
end
