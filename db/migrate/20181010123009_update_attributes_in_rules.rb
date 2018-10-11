class UpdateAttributesInRules < ActiveRecord::Migration[5.2]
  def change
    remove_column :rules, :minimal_stay, :text, default: [], array: true
    remove_column :rules, :check_in_days, :string
    remove_column :rules, :days_multiplier, :integer
    add_column :rules, :flexible_arrival, :boolean, default: false
    add_column :rules, :minimum_stay, :integer

    rename_column :lodgings, :flexible, :flexible_arrival
    add_column :lodgings, :check_in_day, :string
  end
end
