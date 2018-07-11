class UpdateColumnMinimumStayOfPrices < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :minimum_stay, :integer
    add_column :prices, :minimum_stay, :text, default: [], array: true
  end
end
