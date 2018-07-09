class RemoveExtraAttributesOfPrice < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :friday_price, :float
    remove_column :prices, :saturday_price, :float
    remove_column :prices, :sunday_price, :float
    remove_column :prices, :minimum_per_day_price, :float
  end
end
