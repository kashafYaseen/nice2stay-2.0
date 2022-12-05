class AddReferencesInReservations < ActiveRecord::Migration[5.2]
  def change
    add_reference :reservations, :room_type, foreign_key: true
    add_reference :reservations, :rate_plan, foreign_key: true
  end
end
