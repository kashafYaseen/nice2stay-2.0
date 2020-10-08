class AddChannelManagerFieldsToReservation < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :channel_manager_booking_id, :string
    add_column :reservations, :channel_manager_errors, :text
  end
end
