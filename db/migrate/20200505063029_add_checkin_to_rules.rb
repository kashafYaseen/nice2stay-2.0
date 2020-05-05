class AddCheckinToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :rules, :checkin, :string, default: ['any'], array: true
  end
end
