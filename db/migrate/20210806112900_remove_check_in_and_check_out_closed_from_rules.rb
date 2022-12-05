class RemoveCheckInAndCheckOutClosedFromRules < ActiveRecord::Migration[5.2]
  def change
    remove_column :rules, :rr_check_in_closed, :boolean
    remove_column :rules, :rr_check_out_closed, :boolean
  end
end
