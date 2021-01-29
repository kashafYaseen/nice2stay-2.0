class AddOpenGdsCheckinDaysFieldInPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :multiple_checkin_days, :string, default: [], array: true
  end
end
