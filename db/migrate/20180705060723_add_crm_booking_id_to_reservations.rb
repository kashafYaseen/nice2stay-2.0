class AddCrmBookingIdToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :crm_booking_id, :integer
  end
end
