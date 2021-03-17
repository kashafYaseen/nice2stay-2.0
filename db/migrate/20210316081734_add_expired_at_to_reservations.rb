class AddExpiredAtToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :expired_at, :date
  end
end
