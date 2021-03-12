class AddPaymentFieldsToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :open_gds_online_payment, :boolean, default: false
    add_column :reservations, :open_gds_payment_hash, :string
    add_column :reservations, :open_gds_deposit_amount, :decimal, default: 0
  end
end
