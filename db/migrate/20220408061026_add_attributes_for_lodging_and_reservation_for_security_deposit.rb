class AddAttributesForLodgingAndReservationForSecurityDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :lodgings, :deposit, :float
    add_column :reservations, :security_deposit, :float
    add_column :reservations, :include_deposit, :boolean
  end
end
