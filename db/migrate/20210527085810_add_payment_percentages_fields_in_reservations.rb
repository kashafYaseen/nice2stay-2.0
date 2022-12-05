class AddPaymentPercentagesFieldsInReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :pre_payment_percentage, :decimal, default: 30
    add_column :reservations, :final_payment_percentage, :decimal, default: 70
    add_column :reservations, :payment_in_percentage, :boolean, default: true
  end
end
