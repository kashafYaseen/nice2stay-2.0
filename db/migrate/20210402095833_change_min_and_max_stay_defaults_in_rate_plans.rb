class ChangeMinAndMaxStayDefaultsInRatePlans < ActiveRecord::Migration[5.2]
  def change
    change_column_default :rate_plans, :min_stay, from: 0, to: 1
    change_column_default :rate_plans, :max_stay, from: 0, to: 45
  end
end
