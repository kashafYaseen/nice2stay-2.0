class AddPreferredMonthsToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :preferred_months, :string
  end
end
