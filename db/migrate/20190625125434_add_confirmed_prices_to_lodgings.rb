class AddConfirmedPricesToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :confirmed_price_2020, :boolean, default: false
  end
end
