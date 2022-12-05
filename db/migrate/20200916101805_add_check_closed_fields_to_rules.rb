class AddCheckClosedFieldsToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :rules, :rr_check_in_closed, :boolean, default: false
    add_column :rules, :rr_check_out_closed, :boolean, default: false
  end
end
