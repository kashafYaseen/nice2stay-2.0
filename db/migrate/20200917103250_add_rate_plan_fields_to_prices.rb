class AddRatePlanFieldsToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :rr_rate_plan_code, :string
    add_column :prices, :rr_rate_plan_description, :string
  end
end
