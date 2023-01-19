class AddSecurityDepositToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :security_deposit_payment, :float
    unless column_exists? :bookings, :security_deposit_payment_mollie_id
      add_column :bookings, :security_deposit_payment_mollie_id, :string
    end
  end
end
