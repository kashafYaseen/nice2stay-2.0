class UpdateAttributesInRules < ActiveRecord::Migration[5.2]
  def change
    add_column :rules, :flexible_arrival, :boolean, default: false
    remove_column :rules, :minimal_stay, :text, default: [], array: true
    add_column :rules, :minimum_stay, :integer
    rename_column :rules, :check_in_days, :check_in_day
    remove_column :rules, :days_multiplier, :integer
  end
end
