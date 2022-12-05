class RemoveSecurityDepositPaymentFromBookings < ActiveRecord::Migration[5.2]
  def change
    remove_column :bookings, :security_deposit_payment, :float
  end
end
