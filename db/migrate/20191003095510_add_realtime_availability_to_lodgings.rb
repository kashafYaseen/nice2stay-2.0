class AddRealtimeAvailabilityToLodgings < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :realtime_availability, :boolean, default: false
  end
end
