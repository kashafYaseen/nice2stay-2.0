class AddCanceledAtFieldInReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :canceled_at_channel, :datetime
  end
end
