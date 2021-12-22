class AddCanceledByToReservation < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :canceled_by, :string
  end
end
