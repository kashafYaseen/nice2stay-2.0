class AddAttributesToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :min_stay, :integer, default: 0
    add_column :rate_plans, :max_stay, :integer, default: 0
    add_column :rate_plans, :open_gds_daily_supplements, :text
  end
end
