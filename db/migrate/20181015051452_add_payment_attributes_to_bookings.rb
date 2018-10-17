class AddPaymentAttributesToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :pre_payment, :float, default: 0
    add_column :bookings, :final_payment, :float, default: 0
    add_column :bookings, :refund_payment, :boolean, default: false
    add_column :bookings, :pre_payment_mollie_id, :string
    add_column :bookings, :final_payment_mollie_id, :string
  end
end
