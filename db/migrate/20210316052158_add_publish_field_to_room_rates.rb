class AddPublishFieldToRoomRates < ActiveRecord::Migration[5.2]
  def change
    add_column :room_rates, :publish, :boolean, default: true
  end
end
