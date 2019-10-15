class AddGcErrorsToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :gc_errors, :text
  end
end
