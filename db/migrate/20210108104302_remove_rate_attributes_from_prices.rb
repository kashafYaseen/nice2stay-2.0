class RemoveRateAttributesFromPrices < ActiveRecord::Migration[5.2]
  def change
    remove_column :prices, :open_gds_single_rate_type, :integer, default: 0
    remove_column :prices, :open_gds_extra_night_rate, :decimal, default: 0
  end
end
