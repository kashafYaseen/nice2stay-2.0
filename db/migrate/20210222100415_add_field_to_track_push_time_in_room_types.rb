class AddFieldToTrackPushTimeInRoomTypes < ActiveRecord::Migration[5.2]
  def change
    add_column :rate_plans, :opengds_pushed_at, :datetime
  end
end
