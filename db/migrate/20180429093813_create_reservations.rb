class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.references :user, foreign_key: true
      t.references :transaction, foreign_key: true
      t.date :booking_date

      t.timestamps
    end
  end
end
