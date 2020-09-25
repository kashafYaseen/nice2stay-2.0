class AddRatePlanFieldsToDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :discounts, :rr_rate_plan_code, :string
  end
end
