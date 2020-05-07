class AddDefaultValueToMinimumStay < ActiveRecord::Migration[5.2]
  def up
    change_column_default :rules, :minimum_stay, []
  end

  def down
    change_column_default :users, :minimum_stay, nil
  end
end
