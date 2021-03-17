class AddDynamicPricesToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :dynamic_prices, :boolean, default: false
  end
end
