class RenameChildrenColumnInChildRates < ActiveRecord::Migration[5.2]
  def change
    rename_column :child_rates, :children, :open_gds_category
  end
end
