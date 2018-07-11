class UpdateGuestsColumnsInPrices < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :adults, :integer
    add_column :prices, :adults, :text, default: [], array: true

    remove_column :prices, :children, :integer
    add_column :prices, :children, :text, default: [], array: true

    remove_column :prices, :infants, :integer
    add_column :prices, :infants, :text, default: [], array: true
  end
end
