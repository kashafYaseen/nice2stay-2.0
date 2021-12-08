class AddCancelOptionReasonToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :cancel_option_reason, :integer, default: -1
  end
end
