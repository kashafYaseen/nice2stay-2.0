class AddNewAttributesToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :stay, :integer
    add_column :leads, :experience, :integer
    add_column :leads, :budget, :integer
  end
end
