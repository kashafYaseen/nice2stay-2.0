class AddAdditionalGcAttributesToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :meal_tax, :float, default: 0
    add_column :reservations, :tax, :float, default: 0
    add_column :reservations, :additional_fee, :float, default: 0
    add_column :reservations, :remove_type, :string
  end
end
