class AddFieldToTrackPushTimeInRoomTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :room_types, :opengds_push_time, :datetime
  end
end
