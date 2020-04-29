class AddCheckinToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :checkin, :integer, default: 0
  end
end
