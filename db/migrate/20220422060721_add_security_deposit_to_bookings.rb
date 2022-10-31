class AddSecurityDepositToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :security_deposit_payment, :float
    add_column :bookings, :security_deposit_payment_mollie_id, :string
  end
end
