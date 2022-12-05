class ChangeDefaultsForAttributesInRoomRates < ActiveRecord::Migration[5.2]
  def change
    change_column_default :room_rates, :extra_bed_rate, from: 0, to: nil
    change_column_default :room_rates, :extra_night_rate, from: 0, to: nil
  end
end
