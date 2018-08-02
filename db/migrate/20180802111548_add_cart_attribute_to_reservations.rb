class AddCartAttributeToReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :in_cart, :boolean, default: false
  end
end
