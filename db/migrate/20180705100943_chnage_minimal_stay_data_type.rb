class ChnageMinimalStayDataType < ActiveRecord::Migration[5.2]
  def change
    remove_column :rules, :minimal_stay, :integer
    add_column :rules, :minimal_stay, :text, default: [], array: true
  end
end
