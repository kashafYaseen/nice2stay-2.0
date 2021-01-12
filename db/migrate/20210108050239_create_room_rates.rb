class CreateRoomRates < ActiveRecord::Migration[5.2]
  def change
    create_table :room_rates do |t|
      t.integer :default_booking_limit, default: 0
      t.decimal :default_rate, default: 0
      t.string :currency_code
      t.string :default_single_rate, default: 0
      t.integer :default_single_rate_type
      t.decimal :default_single_rate, default: 0
      t.integer :extra_bed_rate_type, default: 0
      t.decimal :extra_bed_rate, default: 0
      t.decimal :extra_night_rate, default: 0
      t.references :room_type, foreign_key: { on_delete: :cascade }
      t.references :rate_plan, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
