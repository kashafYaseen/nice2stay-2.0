class AddMinimalStayToRules < ActiveRecord::Migration[5.2]
  def change
    add_column :rules, :minimal_stay, :integer
  end
end
