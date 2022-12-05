class AddPaymentColumnsInRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :pre_payment_percentage, :integer
    add_column :rate_plans, :pre_payment_hours_limit, :integer
    add_column :rate_plans, :final_payment_days_limit, :integer
  end
end
