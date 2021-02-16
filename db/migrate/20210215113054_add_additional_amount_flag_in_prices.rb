class AddAdditionalAmountFlagInPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :rr_additional_amount_flag, :boolean, default: false
  end
end
