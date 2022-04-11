class AddPaymentAttributesToVouchers < ActiveRecord::Migration[5.2]
  def change
    add_column :vouchers, :sender_mollie_id, :string
    add_column :vouchers, :payment_status, :string
    add_column :vouchers, :payed_at, :datetime
    add_column :vouchers, :mollie_amount, :float, default: 0
    add_column :vouchers, :mollie_payment_id, :string
  end
end
