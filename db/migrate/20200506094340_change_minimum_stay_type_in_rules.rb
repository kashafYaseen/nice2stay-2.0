class ChangeMinimumStayTypeInRules < ActiveRecord::Migration[5.2]
  def up
    change_column :rules, :minimum_stay, :integer, default: [], array: true, using: 'ARRAY[minimum_stay]::INTEGER[]'
  end

  def down
    remove_column :rules, :minimum_stay, :integer
    add_column :rules, :minimum_stay, :integer
  end
end
