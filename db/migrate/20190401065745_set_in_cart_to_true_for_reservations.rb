class SetInCartToTrueForReservations < ActiveRecord::Migration[5.2]
  def up
    change_column :reservations, :in_cart, :boolean, default: true
  end

  def down
    change_column :reservations, :in_cart, :boolean, default: false
  end
end
