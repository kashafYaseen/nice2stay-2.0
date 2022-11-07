class AddOccupancyColumnsInRatePlan < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :min_occupancy, :integer
    add_column :rate_plans, :max_occupancy, :integer
  end
end
