class AddReservationToReviews < ActiveRecord::Migration[5.2]
  def change
    add_reference :reviews, :reservation, index: true
    add_foreign_key :reviews, :reservations, on_delete: :cascade
  end
end
