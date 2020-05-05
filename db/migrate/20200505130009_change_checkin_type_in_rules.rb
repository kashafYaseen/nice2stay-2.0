class ChangeCheckinTypeInRules < ActiveRecord::Migration[5.2]
  def change
    remove_column :rules, :checkin, :string, default: ['any'], array: true
    add_column :rules, :checkin_day, :string
  end
end
