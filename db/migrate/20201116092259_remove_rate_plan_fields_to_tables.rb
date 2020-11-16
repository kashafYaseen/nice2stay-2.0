class RemoveRatePlanFieldsToTables < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :rr_rate_plan_code, :string
    remove_column :prices, :rr_rate_plan_description, :string
    remove_column :discounts, :rr_rate_plan_code, :string
  end
end
