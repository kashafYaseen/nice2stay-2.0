class AddVoucherCodeToBooking < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :voucher_code, :string
    add_column :bookings, :voucher_amount, :float
  end
end
