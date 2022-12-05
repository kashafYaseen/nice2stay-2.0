class AddDescriptionFieldToRatePlans < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :description, :text
  end
end
