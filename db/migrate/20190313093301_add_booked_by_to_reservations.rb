class AddBookedByToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :booked_by, :string
  end
end
