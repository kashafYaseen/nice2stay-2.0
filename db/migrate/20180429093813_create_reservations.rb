class CreateReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :reservations do |t|
      t.references :user, foreign_key: true
      t.references :lodging, foreign_key: true
      t.date :check_in
      t.date :check_out

      t.timestamps
    end
  end
end
