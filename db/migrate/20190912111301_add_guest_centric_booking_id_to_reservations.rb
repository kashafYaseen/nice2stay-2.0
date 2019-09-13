class AddGuestCentricBookingIdToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :guest_centric_booking_id, :string
    add_column :reservations, :offer_id, :string
    add_column :reservations, :meal_id, :string
  end
end
