class AddBeIdentifierToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :be_identifier, :string
  end
end
