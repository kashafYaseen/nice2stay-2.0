class AddBookingsToReservations < ActiveRecord::Migration[5.2]
  def change
    add_reference :reservations, :booking, index: true
    add_foreign_key :reservations, :bookings, on_delete: :cascade
  end
end
