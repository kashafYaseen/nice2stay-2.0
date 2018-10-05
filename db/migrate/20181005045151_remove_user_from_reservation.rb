class RemoveUserFromReservation < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :reservations, :users
    remove_reference :reservations, :user, index: true
  end
end
