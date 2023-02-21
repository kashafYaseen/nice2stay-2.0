class ChangeOwnerNameColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :bookings, :owner_name, :string, default: ''
  end
end
