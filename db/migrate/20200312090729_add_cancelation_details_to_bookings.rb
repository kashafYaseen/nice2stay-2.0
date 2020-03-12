class AddCancelationDetailsToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :final_payment_till, :date
    add_column :bookings, :free_cancelation_till, :date
    add_column :bookings, :free_cancelation, :boolean, default: false
  end
end
