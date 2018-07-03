class AddCrmAttributesToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :weekly_price, :float
    add_column :prices, :friday_price, :float
    add_column :prices, :saturday_price, :float
    add_column :prices, :sunday_price, :float
    add_column :prices, :minimum_per_day_price, :float
    add_column :prices, :minimum_stay, :integer
  end
end
