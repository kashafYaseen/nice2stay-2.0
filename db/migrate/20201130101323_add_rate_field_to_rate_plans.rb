class AddRateFieldToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :default_rate, :decimal, default: 0
  end
end
